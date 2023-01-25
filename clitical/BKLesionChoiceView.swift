//
//  BKLesionChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct BKLesionChoiceView: View {
    var body: some View {
        Text("BKLesionQuestionDescription")
    }
}

struct BKLesionChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        BKLesionChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
