//
//  FeverChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct FeverChoiceView: View {
    var body: some View {
        Text("FeverQuestionDescription")
    }
}

struct FeverChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        FeverChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
