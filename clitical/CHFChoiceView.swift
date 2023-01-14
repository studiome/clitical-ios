//
//  CHFChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/11.
//

import SwiftUI
import CLPatientData

struct CHFChoiceViewBase: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        List{
            Section(footer: Text("CHFQuestionDescription")){
                ForEach(YesNo.allCases, id: \.self){item in
                    HStack{
                        Text(LocalizedStringKey(item.label))
                        Spacer()
                        if(patientData.hasCHF == item.toBool()){
                            Image(systemName: "checkmark")
                                .foregroundColor(jsvsColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.hasCHF = item.toBool()
                    }
                }
            }
        }
        .navigationTitle("CHFQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CHFChoiceView: View {
    var body: some View {
        if #available(iOS 15, *){
            CHFChoiceViewBase()
        } else {
            CHFChoiceViewBase().listStyle(.grouped)
        }
    }
}

struct CHFChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        CHFChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
