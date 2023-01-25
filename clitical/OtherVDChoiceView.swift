//
//  OthersChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct OtherVDChoiceView: View {
    var body: some View {
        Text("OtherVDQuestionDescription")
    }
}

struct OthersChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        OtherVDChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
