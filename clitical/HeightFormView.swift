//
//  HeightFormView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/22.
//

import SwiftUI
import CLPatientData

struct HeightFormView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        HStack{
            Text("HeightQuestionTitle")
            if #available(iOS 15.0, *) {
                TextField("HeightQuestionDescription",
                          value: $patientData.height,
                          format: .number
                ).multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            } else {
                TextField("HeightQuestionDescription",
                          value: $patientData.height,
                          formatter: NumberFormatter()
                ).multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
        }
    }
}

struct HeightFormView_Previews: PreviewProvider {
    static var previews: some View {
        HeightFormView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
