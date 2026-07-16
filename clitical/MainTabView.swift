//
//  MainTabView.swift
//  clitical-ios
//
//  Bottom tab navigation that replaces the Flutter/Android hamburger menu:
//  Risk calculation, Language, References, and About.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            RootContentView()
                .tabItem {
                    Label("RiskCalculationTab", systemImage: "chart.line.uptrend.xyaxis")
                }
            LanguageView()
                .tabItem {
                    Label("Language", systemImage: "globe")
                }
            ReferencesView()
                .tabItem {
                    Label("References", systemImage: "doc.text")
                }
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .tint(.teal)
    }
}

// MARK: - Language

struct LanguageView: View {
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        NavigationView {
            Form {
                Picker("Language", selection: $localization.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
                .pickerStyle(.inline)
            }
            .navigationTitle("Language")
        }
        .tint(.teal)
    }
}

// MARK: - References

struct ReferencesView: View {
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

    var body: some View {
        NavigationView {
            List {
                Section(footer: Text("TapToOpenLink")) {
                    ForEach(references) { reference in
                        Link(destination: reference.url) {
                            Text(reference.text)
                                .font(.callout)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .navigationTitle("References")
        }
        .tint(.teal)
    }
}

// MARK: - About

struct AboutView: View {
    private let termsURL = URL(string: "https://studiome.github.io/clti_risk/")!

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text(verbatim: "CLiTICAL")
                            .font(.largeTitle.bold())
                        Text(verbatim: "Version: \(appVersion)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("AppLegalese")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.top, 8.0)
                    }
                    .padding(.vertical, 4.0)
                }
                Section {
                    Link(destination: termsURL) {
                        Label("AppTerms", systemImage: "hand.raised")
                    }
                }
            }
            .navigationTitle("About")
        }
        .tint(.teal)
    }
}

#Preview {
    MainTabView()
        .environmentObject(LocalizationManager())
        .environment(\.locale, .init(identifier: "ja"))
}
