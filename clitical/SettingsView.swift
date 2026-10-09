//
//  SettingsView.swift
//  clitical-ios
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.openURL) private var openURL

    @State private var selectedLegalDocument: AppInfo.LegalDocument?

    var body: some View {
        NavigationStack {
            Form {
                // The language is the system's per-app setting, not an in-app
                // choice: this row just takes people to it.
                Section(header: Text("Language"), footer: Text("LanguageFooter")) {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    } label: {
                        Label("LanguageOpenSettings", systemImage: "globe")
                    }
                    .accessibilityIdentifier("openLanguageSettings")
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
            .navigationTitle(Text("Settings"))
            .sheet(item: $selectedLegalDocument) { document in
                SafariView(url: AppInfo.legalURL(for: document))
                    .ignoresSafeArea()
            }
        }
    }
}
