//
//  FPLesionChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct FPLesionChoiceView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        List{
            Section(footer: Text("FPLesionQuestionDescription")){
                ForEach(YesNo.allCases, id: \.self){item in
                    HStack{
                        Text(LocalizedStringKey(item.label))
                        Spacer()
                        if(patientData.hasFPLesion == item.toBool()){
                            Image(systemName: "checkmark")
                                .foregroundColor(.teal)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.hasFPLesion = item.toBool()
                    }
                }
            }
        }
        .navigationTitle("FPLesionQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FPLesionChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        FPLesionChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
