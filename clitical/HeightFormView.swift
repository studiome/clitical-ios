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

    var body: some View {
        HStack {
            Text("HeightQuestionTitle")
                .accessibilityHidden(true)
            TextField("HeightQuestionDescription",
                      value: $patientData.height,
                      format: .number)
            .multilineTextAlignment(.trailing)
            .keyboardType(.decimalPad)
            .accessibilityLabel(Text("HeightQuestionTitle"))
        }
    }
}

#Preview {
    HeightFormView(patientData: .constant(PatientData()))
        .environment(\.locale, .init(identifier: "ja"))
}
