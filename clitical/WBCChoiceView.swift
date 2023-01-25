//
//  WBCChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct WBCChoiceView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        List{
            Section(footer: Text("WBCQuestionDescription")){
                ForEach(YesNo.allCases, id: \.self){item in
                    HStack{
                        Text(LocalizedStringKey(item.label))
                        Spacer()
                        if(patientData.hasAbnormalWBC == item.toBool()){
                            Image(systemName: "checkmark")
                                .foregroundColor(.teal)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.hasAbnormalWBC = item.toBool()
                    }
                }
            }
        }
        .navigationTitle("WBCQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WBCChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        WBCChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
