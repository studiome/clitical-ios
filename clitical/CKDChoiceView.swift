//
//  CKDChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct CKDChoiceView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        List{
            Section(footer: Text("CKDQuestionDescription")){
                ForEach(CKD.allCases, id: \.self){item in
                    HStack{
                        Text(LocalizedStringKey(item.label))
                        Spacer()
                        if(patientData.ckd == item){
                            Image(systemName: "checkmark")
                                .foregroundColor(jsvsColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.ckd = item
                    }
                }
            }
        }
        .navigationTitle("CKDQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension CKD {
    var label: String{
        switch self{
        case .normal: return "CKDNormal"
        case .g3: return "CKDG3"
        case .g4: return "CKDG4"
        case .g5: return "CKDG5"
        case .g5D: return "CKDG5D"
        }
    }
}

struct CKDChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        CKDChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
