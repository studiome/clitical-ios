//
//  CHFChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/11.
//

import SwiftUI
import CLPatientData

struct CHFChoiceView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        CHFChoiceBase()
    }
}

private struct CHFChoiceBase: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        Picker(LocalizedStringKey("CHFQuestionTitle"), selection: $patientData.hasCHF){
            ForEach(YesNo.allCases, id:\.self){ item in
                Text(LocalizedStringKey(item.label)).tag(item.toBool())
            }
        }
    }
}
struct CHFChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            Form{
                CHFChoiceView().environmentObject(PatientData())
                    .environment(\.locale, .init(identifier: "ja"))
            }
        }
    }
}
