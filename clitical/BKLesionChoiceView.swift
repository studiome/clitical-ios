//
//  BKLesionChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct BKLesionChoiceView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        List{
            Section(footer: Text("BKLesionQuestionDescription")){
                ForEach(YesNo.allCases, id: \.self){item in
                    HStack{
                        Text(LocalizedStringKey(item.label))
                        Spacer()
                        if(patientData.hasBKLesion == item.toBool()){
                            Image(systemName: "checkmark")
                                .foregroundColor(jsvsColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.hasBKLesion = item.toBool()
                    }
                }
            }
        }
        .navigationTitle("BKLesionQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BKLesionChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        BKLesionChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
