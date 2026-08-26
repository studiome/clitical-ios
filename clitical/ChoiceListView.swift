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
///
/// At accessibility text sizes the label and the switch stack vertically:
/// `Toggle` keeps them side by side however narrow the label gets, which
/// hyphenates single words ("In-frapopliteal") into an unreadable column.
struct ToggleRow: View {
    let title: String        // localization key
    let footer: LocalizedStringKey?
    @Binding var selection: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(title: String,
         footer: LocalizedStringKey? = nil,
         selection: Binding<Bool>) {
        self.title = title
        self.footer = footer
        self._selection = selection
    }

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) {
                label
                Toggle(isOn: $selection) {
                    Text(LocalizedStringKey(title))
                }
                .labelsHidden()
                .accessibilityLabel(Text(LocalizedStringKey(title)))
            }
        } else {
            Toggle(isOn: $selection) {
                label
            }
        }
    }

    private var label: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(LocalizedStringKey(title))
            if let footer {
                Text(footer).font(.footnote).foregroundStyle(.secondary)
            }
        }
    }
}

/// An inline row for a small, fixed set of mutually exclusive options
/// (e.g. Sex) using a segmented control, per HIG guidance to use segmented
/// controls for a handful of closely related choices.
///
/// `Value` may be an optional so that "not answered yet" is representable:
/// a selection that matches no segment leaves the control with nothing
/// selected, which is exactly what an unanswered required question should
/// look like.
struct SegmentedRow<Value: Hashable>: View {
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
            if let footer {
                Text(footer)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
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

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
        // Picker's `.menu` style only lays the current value and chevron out
        // trailing the label when that label is a single line; a multi-line
        // label (title + footer) pushes them onto a new line, left-aligned,
        // breaking the standard leading-title/trailing-value list row. An
        // explicit HStack keeps that layout regardless of the footer — until
        // accessibility text sizes, where there is no room for two columns.
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) {
                titleColumn
                picker
            }
        } else {
            HStack {
                titleColumn
                Spacer()
                picker
            }
        }
    }

    private var titleColumn: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(LocalizedStringKey(title))
            if let footer {
                Text(footer).font(.footnote).foregroundStyle(.secondary)
            }
        }
    }

    private var picker: some View {
        Picker(LocalizedStringKey(title), selection: $selection) {
            ForEach(options, id: \.self) { option in
                Text(LocalizedStringKey(label(option)))
                    .tag(option)
            }
        }
        .labelsHidden()
        .pickerStyle(.menu)
    }
}

#Preview {
    NavigationStack {
        List {
            ToggleRow(title: "SmokingQuestionTitle",
                      footer: "SmokingQuestionDescription",
                      selection: .constant(true))
            SegmentedRow(title: "SexQuestionTitle",
                         footer: "SexRequiredHint",
                         options: Sex.allCases.map(Optional.init),
                         label: { $0?.label ?? "" },
                         selection: .constant(nil))
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
