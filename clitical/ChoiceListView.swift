//
//  ChoiceListView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2026/07/13.
//

import SwiftUI
import CLPatientData

/// A selection screen for a single question: lists every option and marks
/// the current selection with a checkmark.
struct ChoiceListView<Value: Hashable>: View {
    @EnvironmentObject var localization: LocalizationManager
    /// Raw localization key (not `LocalizedStringKey`) so the navigation
    /// title can be resolved explicitly; see `LocalizationManager.string(forKey:)`.
    let title: String
    let footer: LocalizedStringKey
    let options: [Value]
    let label: (Value) -> String
    @Binding var selection: Value

    var body: some View {
        List {
            Section(footer: Text(footer)) {
                Picker(LocalizedStringKey(title), selection: $selection) {
                    ForEach(options, id: \.self) { option in
                        Text(LocalizedStringKey(label(option)))
                            .tag(option)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        }
        .navigationTitle(Text(verbatim: localization.string(forKey: title)))
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// A row in the question list: shows the question title with the current
/// selection, and pushes a ChoiceListView on tap.
struct ChoiceRow<Value: Hashable>: View {
    let title: String
    let footer: LocalizedStringKey
    let options: [Value]
    let label: (Value) -> String
    @Binding var selection: Value

    var body: some View {
        NavigationLink(destination: ChoiceListView(
            title: title,
            footer: footer,
            options: options,
            label: label,
            selection: $selection)
        ) {
            HStack {
                Text(LocalizedStringKey(title))
                Spacer()
                Text(LocalizedStringKey(label(selection)))
            }
        }
    }
}

extension ChoiceRow where Value == Bool {
    /// A yes/no question row.
    init(title: String,
         footer: LocalizedStringKey,
         selection: Binding<Bool>) {
        self.init(title: title,
                  footer: footer,
                  options: [true, false],
                  label: \.label,
                  selection: selection)
    }
}

#Preview {
    NavigationView {
        ChoiceListView(title: "CKDQuestionTitle",
                       footer: "CKDQuestionDescription",
                       options: CKD.allCases,
                       label: \.label,
                       selection: .constant(.normal))
    }
    .environmentObject(LocalizationManager())
    .environment(\.locale, .init(identifier: "ja"))
}
