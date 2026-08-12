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
    var body: some View {
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

// MARK: - App metadata

/// Bundle-provided app identity, read once and shared by Settings and About.
enum AppInfo {
    static let name = "CLiTICAL"
    static let termsURL = URL(string: "https://studiome.github.io/clti_risk/")!

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

    private let termsURL = AppInfo.termsURL

    @State private var isShowingTerms = false

    var body: some View {
        NavigationView {
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
                    Button {
                        isShowingTerms = true
                    } label: {
                        Label("AppTerms", systemImage: "hand.raised")
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
            .sheet(isPresented: $isShowingTerms) {
                SafariView(url: termsURL)
                    .ignoresSafeArea()
            }
        }
    }
}

// MARK: - About

/// Detail screen behind the Settings > About row: what the app does, what it
/// predicts, where the models come from, and the legal/credit fine print.
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
            Section(header: Text("AboutModelSource")) {
                Text("AboutModelSourceBody")
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
        NavigationView {
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

#Preview("About") {
    NavigationView {
        AboutView()
    }
    .environmentObject(LocalizationManager())
    .environment(\.locale, .init(identifier: "ja"))
}
