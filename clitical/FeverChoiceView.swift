//
//  FeverChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct FeverChoiceView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        List{
            Section(footer: Text("FeverQuestionDescription")){
                ForEach(YesNo.allCases, id: \.self){item in
                    HStack{
                        Text(LocalizedStringKey(item.label))
                        Spacer()
                        if(patientData.hasFever == item.toBool()){
                            Image(systemName: "checkmark")
                                .foregroundColor(jsvsColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.hasFever = item.toBool()
                    }
                }
            }
        }
        .navigationTitle("FeverQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeverChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        FeverChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
