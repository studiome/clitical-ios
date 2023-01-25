//
//  WBCChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct WBCChoiceView: View {
    var body: some View {
        Text("WBCQuestionDescription")
    }
}

struct WBCChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        WBCChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
