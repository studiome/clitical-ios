//
//  LocalizationManager.swift
//  clitical-ios
//
//  Provides in-app language switching, mirroring the Flutter/Android
//  LocaleController. The selected language is persisted and applied by
//  overriding the main bundle's localization lookup so that every
//  `Text("key")` re-resolves against the chosen `.lproj`.
//

import Foundation
import SwiftUI

/// Supported UI languages, matching the app's `knownRegions`.
enum AppLanguage: String, CaseIterable, Identifiable {
    case ja
    case en

    var id: String { rawValue }

    /// The language's endonym, shown identically regardless of the active locale.
    var displayName: String {
        switch self {
        case .ja: "日本語"
        case .en: "English"
        }
    }
}

/// Observable holder for the current UI language, backed by `UserDefaults`.
final class LocalizationManager: ObservableObject {
    private static let storageKey = "app_language"

    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: Self.storageKey)
            Bundle.setLanguage(language.rawValue)
            languageBundle = Self.bundle(for: language)
        }
    }

    /// The `.lproj` bundle of the current language, resolved once per change
    /// rather than on every `string(forKey:)` call.
    private var languageBundle: Bundle?

    var locale: Locale { Locale(identifier: language.rawValue) }

    /// Resolves a localization key against the current language, bypassing
    /// `LocalizedStringKey`. `.navigationTitle` bridges to a UIKit
    /// `UINavigationItem` that caches its resolved title and does not
    /// re-localize on its own when only `Bundle.main`'s lookup is swapped, so
    /// callers must feed it a concrete, freshly resolved `String` instead.
    func string(forKey key: String) -> String {
        guard let languageBundle else { return key }
        return languageBundle.localizedString(forKey: key, value: nil, table: nil)
    }

    private static func bundle(for language: AppLanguage) -> Bundle? {
        Bundle.main.path(forResource: language.rawValue, ofType: "lproj")
            .flatMap(Bundle.init(path:))
    }

    init() {
        let resolved = Self.storedLanguage() ?? Self.systemLanguage()
        language = resolved
        languageBundle = Self.bundle(for: resolved)
        Bundle.setLanguage(resolved.rawValue)
    }

    private static func storedLanguage() -> AppLanguage? {
        guard let raw = UserDefaults.standard.string(forKey: storageKey) else { return nil }
        return AppLanguage(rawValue: raw)
    }

    /// Japanese for Japanese speakers, English for everyone else — the app
    /// ships only these two, and defaulting a French or Korean speaker to
    /// Japanese leaves them with a UI they cannot read.
    private static func systemLanguage() -> AppLanguage {
        let preferred = Locale.preferredLanguages.first ?? "en"
        return preferred.hasPrefix("ja") ? .ja : .en
    }
}

// MARK: - Runtime bundle language override

private enum AssociationKeys {
    // The address of this variable is the association key. It is a mutable
    // static only because `objc_*AssociatedObject` takes it as an inout
    // pointer; it is never written to, and `nonisolated(unsafe)` is not
    // available in Swift 5 language mode.
    static var language: UInt8 = 0
}

/// A `Bundle` subclass that reports and resolves a single, explicitly chosen
/// language. Overriding `preferredLocalizations` makes SwiftUI resolve `Text`
/// against the selected `.lproj` even when the system language differs, and the
/// `localizedString` override covers `NSLocalizedString`-style lookups.
private final class LanguageOverrideBundle: Bundle, @unchecked Sendable {
    private var selectedLanguage: String? {
        objc_getAssociatedObject(self, &AssociationKeys.language) as? String
    }

    private var languageBundle: Bundle? {
        guard let language = selectedLanguage,
              let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            return nil
        }
        return Bundle(path: path)
    }

    override var preferredLocalizations: [String] {
        guard let language = selectedLanguage else { return super.preferredLocalizations }
        return [language]
    }

    override func localizedString(forKey key: String,
                                  value: String?,
                                  table tableName: String?) -> String {
        guard let bundle = languageBundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    /// Swaps `Bundle.main`'s class so that subsequent localized lookups resolve
    /// against the given language's resources, regardless of the system language.
    static func setLanguage(_ language: String) {
        object_setClass(Bundle.main, LanguageOverrideBundle.self)
        objc_setAssociatedObject(Bundle.main,
                                 &AssociationKeys.language,
                                 language,
                                 .OBJC_ASSOCIATION_RETAIN)
    }
}
