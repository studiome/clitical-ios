//
//  OthersChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct OtherVDChoiceView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        List{
            Section(footer: Text("OtherVDQuestionDescription")){
                ForEach(YesNo.allCases, id: \.self){item in
                    HStack{
                        Text(LocalizedStringKey(item.label))
                        Spacer()
                        if(patientData.hasOtherVD == item.toBool()){
                            Image(systemName: "checkmark")
                                .foregroundColor(.teal)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.hasOtherVD = item.toBool()
                    }
                }
            }
        }
        .navigationTitle("OtherVDQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct OthersChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        OtherVDChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
