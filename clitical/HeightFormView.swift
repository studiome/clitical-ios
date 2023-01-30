//
//  HeightFormView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/22.
//

import SwiftUI
import CLPatientData
import Combine

struct HeightFormView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
            HStack{
                Text("HeightQuestionTitle")
                    TextField("HeightQuestionDescription",
                              value: $patientData.height,
                              format: .number
                    )
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
    }
    
    private func  heightToString() -> String {
        if(patientData.height == nil){
            return ""
        }else{
            return String(patientData.height!)
        }
    }
}

struct HeightFormView_Previews: PreviewProvider {
    static var previews: some View {
        HeightFormView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
