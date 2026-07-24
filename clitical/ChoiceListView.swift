//
//  ChoiceListView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2026/07/13.
//

import SwiftUI
import CLPatientData

/// An inline yes/no question row backed by a `Toggle`, per Apple HIG
/// guidance to prefer inline controls over a pushed picker screen for
/// simple binary choices.
struct ToggleRow: View {
    let title: String        // localization key
    let footer: LocalizedStringKey
    @Binding var selection: Bool

    var body: some View {
        Toggle(isOn: $selection) {
            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey(title))
                Text(footer).font(.footnote).foregroundStyle(.secondary)
            }
        }
    }
}

/// An inline row for a small, fixed set of mutually exclusive options
/// (e.g. Sex) using a segmented control, per HIG guidance to use segmented
/// controls for a handful of closely related choices.
struct SegmentedRow<Value: Hashable>: View {
    let title: String
    let footer: LocalizedStringKey
    let options: [Value]
    let label: (Value) -> String
    @Binding var selection: Value

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(LocalizedStringKey(title))
            Picker(LocalizedStringKey(title), selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(LocalizedStringKey(label(option)))
                        .tag(option)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            Text(footer)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

/// An inline row for three or more options, presented as a menu Picker so
/// the current selection is visible without leaving the list, per HIG
/// guidance to use a menu (rather than a pushed list) for a longer set of
/// choices.
struct MenuChoiceRow<Value: Hashable>: View {
    let title: String
    let footer: LocalizedStringKey?
    let options: [Value]
    let label: (Value) -> String
    @Binding var selection: Value

    init(title: String,
         footer: LocalizedStringKey? = nil,
         options: [Value],
         label: @escaping (Value) -> String,
         selection: Binding<Value>) {
        self.title = title
        self.footer = footer
        self.options = options
        self.label = label
        self._selection = selection
    }

    var body: some View {
        Picker(selection: $selection) {
            ForEach(options, id: \.self) { option in
                Text(LocalizedStringKey(label(option)))
                    .tag(option)
            }
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey(title))
                if let footer {
                    Text(footer).font(.footnote).foregroundStyle(.secondary)
                }
            }
        }
        .pickerStyle(.menu)
    }
}

#Preview {
    NavigationView {
        List {
            ToggleRow(title: "SmokingQuestionTitle",
                      footer: "SmokingQuestionDescription",
                      selection: .constant(true))
            SegmentedRow(title: "SexQuestionTitle",
                         footer: "SexQuestionDescription",
                         options: Sex.allCases,
                         label: \.label,
                         selection: .constant(.female))
            MenuChoiceRow(title: "CKDQuestionTitle",
                          footer: "CKDQuestionDescription",
                          options: CKD.allCases,
                          label: \.label,
                          selection: .constant(.normal))
        }
    }
    .environmentObject(LocalizationManager())
    .environment(\.locale, .init(identifier: "ja"))
}
