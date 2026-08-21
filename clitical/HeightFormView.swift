//
//  HeightFormView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/22.
//

import SwiftUI
import CLPatientData

struct HeightFormView: View {
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
        Text("HeightQuestionTitle")
            .accessibilityHidden(true)
    }

    private var field: some View {
        TextField("", value: $patientData.height, format: .number)
            .multilineTextAlignment(.trailing)
            .keyboardType(.decimalPad)
            .accessibilityLabel(Text("HeightQuestionTitle"))
    }
}

#Preview {
    HeightFormView(patientData: .constant(PatientData()))
        .environment(\.locale, .init(identifier: "ja"))
}
