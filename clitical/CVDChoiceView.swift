//
//  CVDChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct CVDChoiceView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        List{
            Section(footer: Text("CVDQuestionDescription")){
                ForEach(YesNo.allCases, id: \.self){item in
                    HStack{
                        Text(LocalizedStringKey(item.label))
                        Spacer()
                        if(patientData.hasCVD == item.toBool()){
                            Image(systemName: "checkmark")
                                .foregroundColor(.teal)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.hasCVD = item.toBool()
                    }
                }
            }
        }
        .navigationTitle("CVDQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CVDChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        CVDChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
