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
            Form {
                Section{
                        SexChoiceView()
                } header: {
                    Text("BasicInfo")
                }
                Section{
                    CHFChoiceView()
                } header: {
                    Text("Complications")
                }
            }
            .navigationBarTitle("PatientDataTitle")
        }
        .navigationViewStyle(.stack)
    }
}

struct RootContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootContentView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier:"ja"))
    }
}
