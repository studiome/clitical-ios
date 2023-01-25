//
//  LocalInfectionChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct LocalInfectionChoiceView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        List{
            Section(footer: Text("LocalInfectionQuestionDescription")){
                ForEach(YesNo.allCases, id: \.self){item in
                    HStack{
                        Text(LocalizedStringKey(item.label))
                        Spacer()
                        if(patientData.hasLocalInfection == item.toBool()){
                            Image(systemName: "checkmark")
                                .foregroundColor(jsvsColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.hasLocalInfection = item.toBool()
                    }
                }
            }
        }
        .navigationTitle("LocalInfectionQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LocalInfectionChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        LocalInfectionChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
