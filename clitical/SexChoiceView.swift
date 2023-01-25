//
//  SexChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/10.
//

import SwiftUI
import CLPatientData

struct SexChoiceViewBase: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        List{
            Section(footer: Text("SexQuestionDescription")){
                ForEach(Sex.allCases, id: \.self){item in
                    HStack{
                        Text(LocalizedStringKey(item.label))
                        Spacer()
                        if(patientData.sex == item){
                            Image(systemName: "checkmark")
                                .foregroundColor(.teal)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.sex = item
                    }
                }
            }
        }
        .navigationTitle("SexQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SexChoiceView: View {
    var body: some View {
        if #available(iOS 15, *){
            SexChoiceViewBase()
        } else {
            SexChoiceViewBase().listStyle(.grouped)
        }
    }
}

extension Sex{
    public var label: String{
        switch self{
        case .male: return "SexMale"
        case .female: return "SexFemale"
        }
    }
}

struct SexChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        SexChoiceView().environmentObject(PatientData()).environment(\.locale, .init(identifier: "ja"));
    }
}
