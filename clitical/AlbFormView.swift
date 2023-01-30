//
//  AlbFormView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct AlbFormView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        HStack{
            Text("AlbQuestionTitle")
            TextField("AlbQuestionDescription",
                      value: $patientData.alb,
                      format: .number
            )
            .multilineTextAlignment(.trailing)
            .keyboardType(.decimalPad)
        }
    }
}

struct AlbFormView_Previews: PreviewProvider {
    static var previews: some View {
        AlbFormView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
