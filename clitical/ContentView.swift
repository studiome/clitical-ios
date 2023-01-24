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
    @State var errorMessage: String  = ""
    var body: some View {
        NavigationView{
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
                    HeightFormView().focused($isActive)
                    WeightFormView().focused($isActive)
                }
                Section(header: Text("SocialHistory")){
                    NavigationLink(destination: SmokingChoiceView(), label:{
                        HStack{
                            Text("SmokingQuestionTitle")
                            Spacer()
                            Text(LocalizedStringKey(patientData.isSmoking.label))
                        }
                    })
                }
                Section(header: Text("ClinicalInfo")){
                    AlbFormView().focused($isActive)
                }
                Section(header: Text("LesionInfo")){
                    NavigationLink(destination: AILesionChoiceView(), label:{
                        HStack{
                            Text("AILesionQuestionTitle")
                            Spacer()
                            Text(LocalizedStringKey(patientData.hasAILesion.label))
                        }
                    })
                }
                Section(header: Text("OtherLesionInfo")){}
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
                        errorMessage = QuestionError.NumberFormIsNil.message
                        failure = true
                        return
                    }
                    if (patientData.hasAILesion == false &&
                        patientData.hasFPLesion == false &&
                        patientData.hasBKLesion == false){
                        errorMessage = QuestionError.IrrelevantLesion.message
                        failure = true
                        return
                    }
                    let risk = PatientRisk(of:patientData)
                    failure = false
                }.alert("ErrorTitle", isPresented: $failure){
                    
                } message: {
                    Text(LocalizedStringKey(errorMessage))
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
