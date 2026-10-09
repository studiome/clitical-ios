//
//  AppInfo.swift
//  clitical-ios
//

import SwiftUI

/// Bundle-provided app identity, read once and shared by Settings and About.
enum AppInfo {
    static let name = "CLiTICAL"

    enum LegalDocument: String, CaseIterable, Identifiable, Hashable {
        case terms
        case privacy
        case support

        var id: Self { self }

        var titleKey: LocalizedStringKey {
            switch self {
            case .terms: "AppTerms"
            case .privacy: "AppPrivacyPolicy"
            case .support: "AppSupport"
            }
        }

        var symbolName: String {
            switch self {
            case .terms: "doc.text"
            case .privacy: "hand.raised"
            case .support: "questionmark.circle"
            }
        }
    }

    /// The legal page in the language the system resolved for this app (the
    /// per-app language setting), falling back to English for any language
    /// the app does not ship.
    static func legalURL(for document: LegalDocument) -> URL {
        let language = Bundle.main.preferredLocalizations.first == "ja" ? "ja" : "en"
        return URL(string: "https://studiome.github.io/clitical-legal/\(document.rawValue)/\(language)/")!
    }

    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

    static var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
    }
}
