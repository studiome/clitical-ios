//
//  ContralateralChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct ContralateralChoiceView: View {
    var body: some View {
        Text("ContralateralQuestionDescription")
    }
}

struct ContralateralChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        ContralateralChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
