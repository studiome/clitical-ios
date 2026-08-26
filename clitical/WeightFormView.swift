//
//  WeightFormView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/22.
//

import SwiftUI
import CLPatientData

struct WeightFormView: View {
    @Binding var patientData: PatientData
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
        Text("WeightQuestionTitle")
            .accessibilityHidden(true)
    }

    private var field: some View {
        // A placeholder is what makes an empty row read as an input
        // field at all: without it the row is simply blank.
        TextField("", value: $patientData.weight, format: .number,
                  prompt: Text(verbatim: "--"))
            .multilineTextAlignment(.trailing)
            .keyboardType(.decimalPad)
            .accessibilityLabel(Text("WeightQuestionTitle"))
    }
}

#Preview {
    WeightFormView(patientData: .constant(PatientData()))
        .environment(\.locale, .init(identifier: "ja"))
}
