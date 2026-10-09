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

    static func legalURL(for document: LegalDocument, language: AppLanguage) -> URL {
        return URL(string: "https://studiome.github.io/clitical-legal/\(document.rawValue)/\(language.rawValue)/")!
    }

    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

    static var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
    }
}
