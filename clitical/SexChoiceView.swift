//
//  SexChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/10.
//

import SwiftUI
import CLPatientData

struct SexChoiceView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        
        List{
            Section(footer: Text("SexQuestionDescription")){
                ForEach(Sex.allCases, id: \.self){item in
                    HStack{
                        Text(item.label)
                        Spacer()
                        if(patientData.sex == item){
                            Image(systemName: "checkmark").foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.sex = item
                        print(patientData.sex)
                    }
                }
            }
        }
        .navigationTitle("SexQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SexChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        SexChoiceView().environmentObject(PatientData());
    }
}
