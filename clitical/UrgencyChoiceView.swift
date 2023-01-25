//
//  UrgencyChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct UrgencyChoiceView: View {
    var body: some View {
        Text("UrgencyQuestionDescription")
    }
}

struct UrgencyChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        UrgencyChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
