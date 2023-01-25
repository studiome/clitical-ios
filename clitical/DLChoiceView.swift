//
//  DLChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct DLChoiceView: View {
    var body: some View {
        Text("DLQuestionDescription")
    }
}

struct DLChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        DLChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
