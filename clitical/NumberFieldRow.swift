//
//  NumberFieldRow.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI

/// A titled numeric entry row (age, height, weight, albumin) backed by a
/// `TextField` whose value is `nil` until something is typed.
///
/// The title carries no unit: the unit is a secondary `Text` trailing the
/// field, and the placeholder shows an example value. VoiceOver hears the
/// title and unit together ("Height cm").
///
/// At accessibility text sizes the title and the field stack vertically so
/// the field keeps a usable width.
struct NumberFieldRow<Format: ParseableFormatStyle>: View
    where Format.FormatOutput == String {
    let title: LocalizedStringKey
    let unit: LocalizedStringKey
    /// An example value shown as the placeholder (not localized: digits).
    let example: String
    @Binding var value: Format.FormatInput?
    let format: Format
    let keyboard: UIKeyboardType
    /// Inline validation message shown under the field, if any.
    let errorMessage: String?
    let errorIdentifier: String?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var minimumFieldHeight = 44.0

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) {
                    label
                    HStack {
                        field
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: .infinity, minHeight: minimumFieldHeight)
                        unitText
                    }
                }
            } else {
                HStack {
                    label
                    field
                    unitText
                }
            }
            if let errorMessage {
                InlineErrorLabel(message: errorMessage, identifier: errorIdentifier)
            }
        }
    }

    private var label: some View {
        Text(title)
            .accessibilityHidden(true)
    }

    private var unitText: some View {
        Text(unit)
            .foregroundStyle(.secondary)
            .accessibilityHidden(true)
    }

    private var field: some View {
        // A placeholder is what makes an empty row read as an input
        // field at all: without it the row is simply blank.
        TextField("", value: $value, format: format,
                  prompt: Text(verbatim: example))
            .multilineTextAlignment(.trailing)
            .keyboardType(keyboard)
            .accessibilityLabel(Text(title) + Text(" ") + Text(unit))
    }
}

/// A short validation message shown beneath a field or section: a red
/// footnote with an icon, so the problem is not signalled by colour alone.
/// The icon and text are read as one VoiceOver element.
struct InlineErrorLabel: View {
    let message: String
    var identifier: String?

    var body: some View {
        Label {
            Text(verbatim: message)
        } icon: {
            Image(systemName: "exclamationmark.circle")
        }
        .font(.footnote)
        .foregroundStyle(.red)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(identifier ?? "")
    }
}

extension NumberFieldRow where Format == IntegerFormatStyle<Int> {
    /// A whole-number row (age).
    init(title: LocalizedStringKey, unit: LocalizedStringKey, example: String,
         value: Binding<Int?>, keyboard: UIKeyboardType,
         errorMessage: String? = nil, errorIdentifier: String? = nil) {
        self.init(title: title, unit: unit, example: example, value: value,
                  format: .number, keyboard: keyboard,
                  errorMessage: errorMessage, errorIdentifier: errorIdentifier)
    }
}

extension NumberFieldRow where Format == FloatingPointFormatStyle<Double> {
    /// A decimal row (height, weight, albumin).
    init(title: LocalizedStringKey, unit: LocalizedStringKey, example: String,
         value: Binding<Double?>, keyboard: UIKeyboardType,
         errorMessage: String? = nil, errorIdentifier: String? = nil) {
        self.init(title: title, unit: unit, example: example, value: value,
                  format: .number, keyboard: keyboard,
                  errorMessage: errorMessage, errorIdentifier: errorIdentifier)
    }
}

#Preview {
    List {
        NumberFieldRow(title: "AgeQuestionTitle", unit: "UnitYears", example: "70",
                       value: .constant(nil as Int?),
                       keyboard: .numberPad)
        NumberFieldRow(title: "HeightQuestionTitle", unit: "UnitCM", example: "165",
                       value: .constant(1.7 as Double?),
                       keyboard: .decimalPad,
                       errorMessage: "Height must be between 100 and 250 cm.")
    }
    .environment(\.locale, .init(identifier: "ja"))
}
