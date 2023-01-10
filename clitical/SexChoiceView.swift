//
//  SexChoiceView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/10.
//

import SwiftUI
import CLPatientData

struct SexChoiceView: View {
    @EnvironmentObject var patiendData: PatientData
    var body: some View {
        Text(patiendData.sex == .female ? "Female": "Male")
    }
}

struct SexChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        SexChoiceView().environmentObject(PatientData())
    }
}
