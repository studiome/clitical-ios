//
//  AILesionChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct AILesionChoiceView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        List{
            Section(footer: Text("AILesionQuestionDescription")){
                ForEach(YesNo.allCases, id: \.self){item in
                    HStack{
                        Text(LocalizedStringKey(item.label))
                        Spacer()
                        if(patientData.hasAILesion == item.toBool()){
                            Image(systemName: "checkmark")
                                .foregroundColor(jsvsColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.hasAILesion = item.toBool()
                    }
                }
            }
        }
        .navigationTitle("AILesionQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AILesionChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        AILesionChoiceView().environmentObject(PatientData()).environment(\.locale, .init(identifier: "ja"));
    }
}
