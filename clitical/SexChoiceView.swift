//
//  SexChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/10.
//

import SwiftUI
import CLPatientData

struct SexChoiceView: View {
    var body: some View {
        if #available(iOS 16.0, *) {
            SexChoiceBase().pickerStyle(.navigationLink)
        } else {
            SexChoiceBase()
        }
    }
}

private struct SexChoiceBase: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        Picker(LocalizedStringKey("SexQuestionTitle"), selection: $patientData.sex){
                    ForEach(Sex.allCases, id: \.self){ item in
                        Text(LocalizedStringKey(item.label)).tag(item)
                    }

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
        NavigationView{
            Form{
                SexChoiceView().environmentObject(PatientData()).environment(\.locale, .init(identifier: "ja"))
            }
        }
    }
}
