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

// MARK: - Settings

struct SettingsView: View {
    @EnvironmentObject var localization: LocalizationManager

    private let termsURL = URL(string: "https://studiome.github.io/clti_risk/")!

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

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
                    HStack {
                        Text(verbatim: "CLiTICAL")
                        Spacer()
                        Text(verbatim: appVersion)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $isShowingTerms) {
                SafariView(url: termsURL)
                    .ignoresSafeArea()
            }
        }
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
            .navigationTitle("References")
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
