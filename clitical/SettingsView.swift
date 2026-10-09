//
//  SettingsView.swift
//  clitical-ios
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var localization: LocalizationManager

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
