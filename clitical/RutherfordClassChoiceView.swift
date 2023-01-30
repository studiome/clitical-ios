//
//  RutherfordClassChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct RutherfordClassChoiceView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        List{
            Section(footer: Text("RutherfordClassQuestionDescription")){
                ForEach(RutherfordClassification.allCases, id: \.self){item in
                    HStack{
                        Text(LocalizedStringKey(item.label))
                        Spacer()
                        if(patientData.rutherford == item){
                            Image(systemName: "checkmark")
                                .foregroundColor(.teal)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        patientData.rutherford = item
                    }
                }
            }
        }
        .navigationTitle("RutherfordClassQuestionTitle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension RutherfordClassification{
    var label: String{
        switch self{
        case .class4: return "Rutherford4"
        case .class5: return "Rutherford5"
        case .class6: return "Rutherford6"
        }
    }
}
struct RutherfordClassChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        RutherfordClassChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
