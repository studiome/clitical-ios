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

    var body: some View {
        HStack {
            Text("AlbQuestionTitle")
            TextField("AlbQuestionDescription",
                      value: $patientData.alb,
                      format: .number)
            .multilineTextAlignment(.trailing)
            .keyboardType(.decimalPad)
        }
    }
}

#Preview {
    AlbFormView(patientData: .constant(PatientData()))
        .environment(\.locale, .init(identifier: "ja"))
}
