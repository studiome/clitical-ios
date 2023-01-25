//
//  LocalInfectionChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct LocalInfectionChoiceView: View {
    var body: some View {
        Text("LocalInfectionQuestionDescription")
    }
}

struct LocalInfectionChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        LocalInfectionChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
