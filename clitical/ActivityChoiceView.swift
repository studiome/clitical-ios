//
//  ActivityChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct ActivityChoiceView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        List{
            Section(footer: Text("ActivityQuestionDescription")){
                ForEach(Activity.allCases, id: \.self){item in
                    HStack{
                        Text(LocalizedStringKey(item.label))
                        Spacer()
                        if(patientData.activity == item){
                            Image(systemName: "checkmark")
                                .foregroundColor(jsvsColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.activity = item
                    }
                }
            }
        }
        .navigationTitle("ActivityQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension Activity {
    var label: String{
        switch self{
        case .ambulatory: return "ActivityAmbulatory"
        case .wheelchair: return "ActivityWheelchair"
        case .immobile: return "ActivityImmobile"
        }
    }
}
struct ActivityChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
