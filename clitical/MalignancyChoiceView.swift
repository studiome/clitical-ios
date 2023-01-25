//
//  MalignancyChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct MalignancyChoiceView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        List{
            Section(footer: Text("MalignancyQuestionDescription")){
                ForEach(MalignantNeoplasm.allCases, id: \.self){item in
                    HStack{
                        Text(LocalizedStringKey(item.label))
                        Spacer()
                        if(patientData.malignantNeoplasm == item){
                            Image(systemName: "checkmark")
                                .foregroundColor(jsvsColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.malignantNeoplasm = item
                    }
                }
            }
        }
        .navigationTitle("MalignancyQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension MalignantNeoplasm{
    var label: String{
        switch self{
        case .no: return "MalignancyNo"
        case .pastHistory: return "MalignancyPast"
        case .underTreatment: return "MalignancyTreatment"
        }
    }
}

struct MalignancyChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        MalignancyChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
