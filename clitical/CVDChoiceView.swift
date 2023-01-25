//
//  CVDChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct CVDChoiceView: View {
    var body: some View {
        Text("CVDQuestionDescription")
    }
}

struct CVDChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        CVDChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
