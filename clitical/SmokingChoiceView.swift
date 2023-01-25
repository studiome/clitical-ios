//
//  SmokingChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct SmokingChoiceView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        List{
            Section(footer: Text("SmokingQuestionDescription")){
                ForEach(YesNo.allCases, id: \.self){item in
                    HStack{
                        Text(LocalizedStringKey(item.label))
                        Spacer()
                        if(patientData.isSmoking == item.toBool()){
                            Image(systemName: "checkmark")
                                .foregroundColor(.teal)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.isSmoking = item.toBool()
                    }
                }
            }
        }
        .navigationTitle("SmokingCHFQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SmokingChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        SmokingChoiceView().environmentObject(PatientData()).environment(\.locale, .init(identifier: "ja"));
    }
}
