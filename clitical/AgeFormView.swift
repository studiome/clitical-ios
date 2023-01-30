//
//  AgeFormView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct AgeFormView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        HStack{
            Text("AgeQuestionTitle")
            TextField("AgeQuestionDescription",
                      value: $patientData.age,
                      format: .number
            )
            .multilineTextAlignment(.trailing)
            .keyboardType(.numberPad)
        }
    }
}

struct AgeFormView_Previews: PreviewProvider {
    static var previews: some View {
        AgeFormView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
