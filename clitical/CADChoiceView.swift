//
//  CADChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import SwiftUI
import CLPatientData

struct CADChoiceView: View {
    
    var body: some View {
        Text("CADQuestionDescription")
    }
}

struct CADChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        CADChoiceView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier: "ja"))
    }
}
