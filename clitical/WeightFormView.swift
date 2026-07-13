//
//  WeightFormView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/22.
//

import SwiftUI
import CLPatientData

struct WeightFormView: View {
    @EnvironmentObject var patientData: PatientData

    var body: some View {
        HStack {
            Text("WeightQuestionTitle")
            TextField("WeightQuestionDescription",
                      value: $patientData.weight,
                      format: .number)
            .multilineTextAlignment(.trailing)
            .keyboardType(.decimalPad)
        }
    }
}

#Preview {
    WeightFormView()
        .environmentObject(PatientData())
        .environment(\.locale, .init(identifier: "ja"))
}
