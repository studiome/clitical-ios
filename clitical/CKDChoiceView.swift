//
//  CKDChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct CKDChoiceView: View {
    var body: some View {
        Text("CKDQuestionDescription")
    }
}

struct CKDChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        CKDChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
