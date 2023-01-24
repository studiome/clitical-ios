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
    @FocusState var isActive: Bool
    @State var failure: Bool = false
    var body: some View {
        NavigationView{
            VStack{
                List{
                    Section(header: Text("BasicInfo")){
                        AgeFormView().focused($isActive)
                        NavigationLink(destination: SexChoiceView(), label:{
                            HStack{
                                Text("SexQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.sex.label))
                            }
                        })
                        WeightFormView().focused($isActive)
                        HeightFormView().focused($isActive)
                    }
                    Section(header: Text("SocialHistory")){}
                    Section(header: Text("ClinicalInfo")){
                        AlbFormView().focused($isActive)
                    }
                    Section(header: Text("LesionInfo")){}
                    Section(header: Text("Complications")){
                        NavigationLink(destination: CHFChoiceView(), label:{
                            HStack{
                                Text("CHFQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.hasCHF.label))
                            }
                        })
                    }
                        Button("PredictRisks"){
                            if(patientData.age == nil ||
                               patientData.height == nil ||
                               patientData.weight == nil ||
                               patientData.alb == nil){
                                failure = true
                                return
                            }
                                failure = false
                        }.alert("ErrorTitle", isPresented: $failure){
                            
                        } message: {
                            Text("NumberFieldErrorMessage")
                        }.buttonStyle(.borderless)
                }
                .toolbar{
                    ToolbarItemGroup(placement: .keyboard){
                        Spacer()
                        Button("DONE"){
                            isActive = false
                        }
                    }
                }
              
            }
            .navigationTitle("PatientDataTitle")
        }
        .accentColor(jsvsColor)
    }
}

struct RootContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootContentView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier:"ja"))
    }
}
