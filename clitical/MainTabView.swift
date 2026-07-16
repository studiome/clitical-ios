//
//  MainTabView.swift
//  clitical-ios
//
//  Bottom tab navigation that replaces the Flutter/Android hamburger menu:
//  Risk calculation, Language, References, and About.
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

    @State private var selectedReference: Reference?

    var body: some View {
        NavigationView {
            List {
                Section(footer: Text("TapToOpenLink")) {
                    ForEach(references) { reference in
                        Button {
                            selectedReference = reference
                        } label: {
                            Text(reference.text)
                                .font(.callout)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .navigationTitle("References")
            .sheet(item: $selectedReference) { reference in
                SafariView(url: reference.url)
                    .ignoresSafeArea()
            }
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

    @State private var isShowingTerms = false

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
                    Button {
                        isShowingTerms = true
                    } label: {
                        Label("AppTerms", systemImage: "hand.raised")
                    }
                }
            }
            .navigationTitle("About")
            .sheet(isPresented: $isShowingTerms) {
                SafariView(url: termsURL)
                    .ignoresSafeArea()
            }
        }
        .tint(.teal)
    }
}

#Preview {
    MainTabView()
        .environmentObject(LocalizationManager())
        .environment(\.locale, .init(identifier: "ja"))
}
