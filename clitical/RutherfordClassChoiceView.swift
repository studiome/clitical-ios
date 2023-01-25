//
//  RutherfordClassChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct RutherfordClassChoiceView: View {
    var body: some View {
        Text("RutherfordClassQuestionDescription")
    }
}

struct RutherfordClassChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        RutherfordClassChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
