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
        HStack{
            Text("WeightQuestionTitle")
            if #available(iOS 15.0, *) {
                TextField("WeightQuestionDescription",
                          value: $patientData.weight,
                          format: .number
                ).multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)
            } else {
                TextField("WeightQuestionDescription",
                          value: $patientData.weight,
                          formatter: NumberFormatter()
                ).multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)
            }
        }
        }
}

struct WeightFormView_Previews: PreviewProvider {
    static var previews: some View {
        WeightFormView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
