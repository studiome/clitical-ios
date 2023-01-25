//
//  ContralateralChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct ContralateralChoiceView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        List{
            Section(footer: Text("ContralateralQuestionDescription")){
                ForEach(YesNo.allCases, id: \.self){item in
                    HStack{
                        Text(LocalizedStringKey(item.label))
                        Spacer()
                        if(patientData.hasContraLateralLesion == item.toBool()){
                            Image(systemName: "checkmark")
                                .foregroundColor(.teal)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.hasContraLateralLesion = item.toBool()
                    }
                }
            }
        }
        .navigationTitle("ContralateralQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ContralateralChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        ContralateralChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
