//
//  UrgencyChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct UrgencyChoiceView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        List{
            Section(footer: Text("UrgencyQuestionDescription")){
                ForEach(YesNo.allCases, id: \.self){item in
                    HStack{
                        Text(LocalizedStringKey(item.label))
                        Spacer()
                        if(patientData.isUrgent == item.toBool()){
                            Image(systemName: "checkmark")
                                .foregroundColor(.teal)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.isUrgent = item.toBool()
                    }
                }
            }
        }
        .navigationTitle("UrgencyQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct UrgencyChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        UrgencyChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
