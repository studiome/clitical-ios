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
/// At accessibility text sizes the title and the field stack vertically so
/// the field keeps a usable width.
struct NumberFieldRow<Format: ParseableFormatStyle>: View
    where Format.FormatOutput == String {
    let title: LocalizedStringKey
    @Binding var value: Format.FormatInput?
    let format: Format
    let keyboard: UIKeyboardType

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) {
                label
                field
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
        } else {
            HStack {
                label
                field
            }
        }
    }

    private var label: some View {
        Text(title)
            .accessibilityHidden(true)
    }

    private var field: some View {
        // A placeholder is what makes an empty row read as an input
        // field at all: without it the row is simply blank.
        TextField("", value: $value, format: format,
                  prompt: Text(verbatim: "--"))
            .multilineTextAlignment(.trailing)
            .keyboardType(keyboard)
            .accessibilityLabel(Text(title))
    }
}

extension NumberFieldRow where Format == IntegerFormatStyle<Int> {
    /// A whole-number row (age).
    init(title: LocalizedStringKey, value: Binding<Int?>, keyboard: UIKeyboardType) {
        self.init(title: title, value: value, format: .number, keyboard: keyboard)
    }
}

extension NumberFieldRow where Format == FloatingPointFormatStyle<Double> {
    /// A decimal row (height, weight, albumin).
    init(title: LocalizedStringKey, value: Binding<Double?>, keyboard: UIKeyboardType) {
        self.init(title: title, value: value, format: .number, keyboard: keyboard)
    }
}

#Preview {
    List {
        NumberFieldRow(title: "AgeQuestionTitle",
                       value: .constant(nil as Int?),
                       keyboard: .numberPad)
        NumberFieldRow(title: "HeightQuestionTitle",
                       value: .constant(nil as Double?),
                       keyboard: .decimalPad)
    }
    .environment(\.locale, .init(identifier: "ja"))
}
