//
//  ActivityChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct ActivityChoiceView: View {
    var body: some View {
        Text("ActivityQuestionDescription")
    }
}

struct ActivityChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
