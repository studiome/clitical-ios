//
//  MainTabView.swift
//  clitical-ios
//
//  Bottom tab navigation that replaces the Flutter/Android hamburger menu:
//  Risk calculation, References, and Settings. Per the HIG, tabs are for
//  content areas, so settings-like items (language, terms, app info) are
//  grouped in a single Settings tab instead of holding tabs of their own.
//

import SwiftUI
import SafariServices

// MARK: - SafariView

private struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - MainTabView

struct MainTabView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab: AppSection = .riskCalculation
    @State private var selectedSection: AppSection? = .riskCalculation

    var body: some View {
        if #available(iOS 18.0, *) {
            adaptableTabRoot
        } else if horizontalSizeClass == .regular {
            NavigationSplitView {
                sidebar
            } detail: {
                splitViewDetail
            }
        } else {
            tabRoot
        }
    }

    @available(iOS 18.0, *)
    private var adaptableTabRoot: some View {
        TabView(selection: $selectedTab) {
            Tab("RiskCalculationTab", systemImage: "chart.line.uptrend.xyaxis", value: AppSection.riskCalculation) {
                RootContentView()
            }
            Tab("References", systemImage: "doc.text", value: AppSection.references) {
                ReferencesView()
            }
            Tab("Settings", systemImage: "gearshape", value: AppSection.settings) {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }

    @ViewBuilder
    private var sidebar: some View {
        if #available(iOS 17.0, *) {
            List(AppSection.allCases, selection: $selectedSection) { section in
                NavigationLink(value: section) {
                    Label(section.titleKey, systemImage: section.symbolName)
                }
                .accessibilityIdentifier(section.rawValue)
            }
            .adaptiveSidebarStyle()
            .navigationTitle(Text(verbatim: AppInfo.name))
        } else {
            List {
                ForEach(AppSection.allCases) { section in
                    Button {
                        selectedSection = section
                    } label: {
                        Label(section.titleKey, systemImage: section.symbolName)
                    }
                    .accessibilityIdentifier(section.rawValue)
                    .foregroundStyle(.primary)
                    .listRowBackground(
                        selectedSection == section ? Color.accentColor.opacity(0.12) : nil
                    )
                }
            }
            .navigationTitle(Text(verbatim: AppInfo.name))
        }
    }

    private var splitViewDetail: some View {
        ZStack {
            splitViewSection(.riskCalculation) {
                RootContentView()
            }
            splitViewSection(.references) {
                ReferencesView()
            }
            splitViewSection(.settings) {
                SettingsView()
            }
        }
    }

    private func splitViewSection<Content: View>(
        _ section: AppSection,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let isSelected = selectedSection == section
        return content()
            .opacity(isSelected ? 1 : 0)
            .allowsHitTesting(isSelected)
            .accessibilityHidden(!isSelected)
    }

    private var tabRoot: some View {
        TabView {
            RootContentView()
                .tabItem {
                    Label("RiskCalculationTab", systemImage: "chart.line.uptrend.xyaxis")
                }
            ReferencesView()
                .tabItem {
                    Label("References", systemImage: "doc.text")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

@available(iOS 17.0, *)
private extension View {
    func adaptiveSidebarStyle() -> some View {
        contentMargins(.horizontal, 8, for: .scrollContent)
    }
}

private enum AppSection: String, CaseIterable, Identifiable {
    case riskCalculation
    case references
    case settings

    var id: Self { self }

    var titleKey: LocalizedStringKey {
        switch self {
        case .riskCalculation: "RiskCalculationTab"
        case .references: "References"
        case .settings: "Settings"
        }
    }

    var symbolName: String {
        switch self {
        case .riskCalculation: "chart.line.uptrend.xyaxis"
        case .references: "doc.text"
        case .settings: "gearshape"
        }
    }

}

// MARK: - App metadata

/// Bundle-provided app identity, read once and shared by Settings and About.
enum AppInfo {
    static let name = "CLiTICAL"

    enum LegalDocument: CaseIterable, Identifiable, Hashable {
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
        let page: String
        switch document {
        case .terms: page = "terms"
        case .privacy: page = "privacy"
        case .support: page = "support"
        }
        let locale = language == .ja ? "ja" : "en"
        return URL(string: "https://studiome.github.io/clitical-legal/\(page)/\(locale)/")!
    }

    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

    static var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
    }
}

// MARK: - Settings

struct SettingsView: View {
    @EnvironmentObject var localization: LocalizationManager

    @State private var selectedLegalDocument: AppInfo.LegalDocument?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Language")) {
                    Picker("Language", selection: $localization.language) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                Section {
                    ForEach(AppInfo.LegalDocument.allCases) { document in
                        Button {
                            selectedLegalDocument = document
                        } label: {
                            Label(document.titleKey, systemImage: document.symbolName)
                        }
                    }
                }
                Section(header: Text("About"), footer: Text("AppLegalese")) {
                    HStack {
                        Text(verbatim: AppInfo.name)
                        Spacer()
                        Text(verbatim: AppInfo.version)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(Text(verbatim: localization.string(forKey: "Settings")))
            .sheet(item: $selectedLegalDocument) { document in
                SafariView(url: AppInfo.legalURL(for: document, language: localization.language))
                    .ignoresSafeArea()
            }
        }
    }
}

// MARK: - References

struct ReferencesView: View {
    @EnvironmentObject var localization: LocalizationManager

    private struct Reference: Identifiable {
        let id = UUID()
        let text: String
        let url: URL
    }

    private let references: [Reference] = [
        Reference(
            text: "1. Miyata T. et al, Risk prediction model for early outcomes of revascularization for chronic limb-threatening ischaemia. Br J Surg. 2022 Oct 14;109(11):1123.",
            url: URL(string: "https://doi.org/10.1093/bjs/znab036")!
        ),
        Reference(
            text: "2. Miyata T. et al, Prediction Models for Two Year Overall Survival and Amputation Free Survival After Revascularisation for Chronic Limb Threatening Ischaemia. Eur J Vasc Endovasc Surg. 2022 Jun 7;S1078-5884(22)00340-9.",
            url: URL(string: "https://doi.org/10.1016/j.ejvs.2022.05.038")!
        ),
    ]

    @State private var selectedReference: Reference?

    var body: some View {
        NavigationStack {
            List {
                Section(footer: Text("TapToOpenLink")) {
                    ForEach(references) { reference in
                        Button {
                            selectedReference = reference
                        } label: {
                            // Keep the citation body in primary for
                            // readability; the accent-colored external-link
                            // symbol is what marks the row as tappable.
                            HStack(alignment: .firstTextBaseline) {
                                Text(reference.text)
                                    .font(.callout)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.accentColor)
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text(verbatim: localization.string(forKey: "References")))
            .sheet(item: $selectedReference) { reference in
                SafariView(url: reference.url)
                    .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(LocalizationManager())
        .environment(\.locale, .init(identifier: "ja"))
}
