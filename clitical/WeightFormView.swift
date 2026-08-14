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

    var body: some View {
        HStack {
            Text("WeightQuestionTitle")
                .accessibilityHidden(true)
            TextField("",
                      value: $patientData.weight,
                      format: .number)
            .multilineTextAlignment(.trailing)
            .keyboardType(.decimalPad)
            .accessibilityLabel(Text("WeightQuestionTitle"))
        }
    }
}

#Preview {
    WeightFormView(patientData: .constant(PatientData()))
        .environment(\.locale, .init(identifier: "ja"))
}
