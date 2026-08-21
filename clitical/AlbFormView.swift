//
//  AlbFormView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct AlbFormView: View {
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
        Text("AlbQuestionTitle")
            .accessibilityHidden(true)
    }

    private var field: some View {
        TextField("", value: $patientData.alb, format: .number)
            .multilineTextAlignment(.trailing)
            .keyboardType(.decimalPad)
            .accessibilityLabel(Text("AlbQuestionTitle"))
    }
}

#Preview {
    AlbFormView(patientData: .constant(PatientData()))
        .environment(\.locale, .init(identifier: "ja"))
}
