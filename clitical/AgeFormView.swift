//
//  AgeFormView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct AgeFormView: View {
    @Binding var patientData: PatientData

    var body: some View {
        HStack {
            Text("AgeQuestionTitle")
                .accessibilityHidden(true)
            TextField("",
                      value: $patientData.age,
                      format: .number)
            .multilineTextAlignment(.trailing)
            .keyboardType(.numberPad)
            .accessibilityLabel(Text("AgeQuestionTitle"))
        }
    }
}

#Preview {
    AgeFormView(patientData: .constant(PatientData()))
        .environment(\.locale, .init(identifier: "ja"))
}
