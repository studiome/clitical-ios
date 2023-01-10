//
//  ContentView.swift
//  clitical
//
//  Created by kmiyahara on 2022/12/20.
//

import SwiftUI
import CLPatientData

struct RootContentView: View {
    @EnvironmentObject var patientData: PatientData
    var body: some View {
        NavigationView{
            List{
                NavigationLink(destination: SexChoiceView(), label:{
                    HStack{
                        Text("SexQuestionTitle")
                        Spacer()
                        Text(patientData.sex.label).foregroundColor(.secondary)
                    }
                })
            }.navigationTitle("Patient Data")
        }
    }
}

struct RootContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootContentView().environmentObject(PatientData()).environment(\.locale, .init(identifier:"ja"))
    }
}
