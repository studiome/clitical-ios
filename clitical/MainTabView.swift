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

// MARK: - Intended use notice

/// Versioned record of the reader's acknowledgement of the intended-use notice.
enum IntendedUseDisclaimer {
    static let storageKey = "intended_use_disclaimer_version"

    /// Bump whenever the notice's wording changes materially, so that an
    /// acknowledgement of the older wording no longer counts.
    /// `cliticalUITests` passes this value as a launch argument to start past
    /// the notice; keep the two in sync.
    static let currentVersion = "2026-08"
}

/// Shows the intended-use notice in place of the app until it is acknowledged.
/// The app prints post-operative mortality figures, so what it is — a
/// calculator of published models for clinicians — and what it is not — a
/// medical device that diagnoses or treats — has to be stated before the first
/// value appears, not only in Settings.
struct IntendedUseGate<Content: View>: View {
    @AppStorage(IntendedUseDisclaimer.storageKey) private var acknowledgedVersion = ""

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        if acknowledgedVersion == IntendedUseDisclaimer.currentVersion {
            content
        } else {
            IntendedUseDisclaimerView {
                acknowledgedVersion = IntendedUseDisclaimer.currentVersion
            }
        }
    }
}

struct IntendedUseDisclaimerView: View {
    @EnvironmentObject var localization: LocalizationManager

    let onAcknowledge: () -> Void

    @State private var isShowingTerms = false

    /// One section per point, keyed by its title so the body string is simply
    /// the title key plus `Body`, as elsewhere in the app.
    private struct Point: Identifiable {
        let id: String
        let symbol: String

        var title: LocalizedStringKey { LocalizedStringKey(id) }
        var detail: LocalizedStringKey { LocalizedStringKey(id + "Body") }
    }

    private let points: [Point] = [
        Point(id: "DisclaimerIntendedUser", symbol: "stethoscope"),
        Point(id: "DisclaimerNotADevice", symbol: "shield.lefthalf.filled"),
        Point(id: "DisclaimerValues", symbol: "function"),
        Point(id: "DisclaimerPopulation", symbol: "chart.bar.doc.horizontal"),
        Point(id: "DisclaimerResponsibility", symbol: "person.text.rectangle"),
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    header
                }
                ForEach(points) { point in
                    Section {
                        Text(point.detail)
                            .font(.callout)
                    } header: {
                        Label(point.title, systemImage: point.symbol)
                    }
                }
                Section {
                    Button {
                        isShowingTerms = true
                    } label: {
                        Label("DisclaimerReadTerms", systemImage: "doc.text")
                    }
                }
            }
            .navigationTitle(Text(verbatim: localization.string(forKey: "DisclaimerTitle")))
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                acknowledgeBar
            }
            .sheet(isPresented: $isShowingTerms) {
                SafariView(url: AppInfo.legalURL(for: .terms, language: localization.language))
                    .ignoresSafeArea()
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8.0) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36.0))
                .foregroundColor(.accentColor)
                .accessibilityHidden(true)
            Text("DisclaimerHeadline")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8.0)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("intendedUseNotice")
    }

    private var acknowledgeBar: some View {
        VStack(spacing: 8.0) {
            Button(action: onAcknowledge) {
                Text("DisclaimerAcknowledge")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 28.0)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("acknowledgeDisclaimer")
            Text("DisclaimerAcknowledgeFooter")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.bar)
    }
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
                    NavigationLink {
                        AboutView()
                    } label: {
                        HStack {
                            Text(verbatim: AppInfo.name)
                            Spacer()
                            Text(verbatim: AppInfo.version)
                                .foregroundStyle(.secondary)
                        }
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

// MARK: - About

/// Detail screen behind the Settings > About row: what the app is for, what it
/// predicts, how the values are derived, where the models come from and what
/// they do not cover. Guideline 1.4.1 asks a medical app to disclose its data
/// and methodology, so this screen — not an external web page — is where that
/// disclosure lives.
struct AboutView: View {
    @EnvironmentObject var localization: LocalizationManager

    private struct Prediction: Identifiable {
        let id: String
        let icon: String
        var title: LocalizedStringKey { LocalizedStringKey(id) }
    }

    /// The predicted indices, mirroring the order and symbols used on the
    /// results screen so the two read as the same list.
    private let predictions: [Prediction] = [
        Prediction(id: "30DDeathOrAmputation", icon: "staroflife"),
        Prediction(id: "30DMALE", icon: "bed.double"),
        Prediction(id: "2YOS", icon: "staroflife"),
        Prediction(id: "2YAFS", icon: "figure.walk"),
        Prediction(id: "GeriatricNutritionalRiskIndex", icon: "flame"),
    ]

    var body: some View {
        List {
            Section {
                header
            }
            Section(header: Text("AboutOverview")) {
                Text("AboutOverviewBody")
                    .font(.callout)
            }
            Section(header: Text("AboutIntendedUse")) {
                Text("AboutIntendedUseBody")
                    .font(.callout)
            }
            Section(header: Text("AboutPredictions"),
                    footer: Text("AboutPredictionsFooter")) {
                ForEach(predictions) { prediction in
                    Label {
                        Text(prediction.title)
                            .font(.callout)
                    } icon: {
                        Image(systemName: prediction.icon)
                            .foregroundColor(.accentColor)
                    }
                    // The symbol only echoes the title, so VoiceOver reads
                    // the row as a single label.
                    .accessibilityElement(children: .combine)
                }
            }
            Section(header: Text("AboutMethodology")) {
                Text("AboutMethodologyBody")
                    .font(.callout)
            }
            Section(header: Text("AboutModelSource")) {
                Text("AboutModelSourceBody")
                    .font(.callout)
            }
            Section(header: Text("AboutLimitations")) {
                Text("AboutLimitationsBody")
                    .font(.callout)
            }
            Section(header: Text("AboutPrivacy")) {
                Text("AboutPrivacyBody")
                    .font(.callout)
            }
            Section(header: Text("AboutDisclaimer")) {
                Text("AboutDisclaimerBody")
                    .font(.callout)
            }
            Section(header: Text("AboutCredits")) {
                creditRow(label: "AboutPublisher", value: "AboutPublisherName")
                creditRow(label: "AboutDeveloper", value: "AboutDeveloperName")
                creditRow(label: "AboutVersion", verbatim: AppInfo.version)
                creditRow(label: "AboutBuild", verbatim: AppInfo.build)
            }
        }
        .navigationTitle(Text(verbatim: localization.string(forKey: "About")))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 8.0) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40.0))
                .foregroundColor(.accentColor)
                .accessibilityHidden(true)
            Text(verbatim: AppInfo.name)
                .font(.title.weight(.semibold))
            Text("AboutTagline")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8.0)
        .accessibilityElement(children: .combine)
    }

    /// A label/value pair. Stacked vertically rather than side by side so long
    /// organisation names stay readable at large Dynamic Type sizes.
    private func creditRow(label: LocalizedStringKey, value: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 2.0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.callout)
        }
        .accessibilityElement(children: .combine)
    }

    private func creditRow(label: LocalizedStringKey, verbatim value: String) -> some View {
        VStack(alignment: .leading, spacing: 2.0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(verbatim: value)
                .font(.callout)
        }
        .accessibilityElement(children: .combine)
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
