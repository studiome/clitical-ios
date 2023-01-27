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
    @State var riskCalculated: Bool = false
    @State var errorMessage: String  = ""
    @State var risk: PatientRisk?
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
                        NavigationLink(destination: ActivityChoiceView(), label:{
                            HStack{
                                Text("ActivityQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.activity.label))
                            }
                        })
                    }
                    Section(header: Text("ClinicalInfo")){
                        AlbFormView().focused($isActive)
                        NavigationLink(destination: CKDChoiceView(), label:{
                            HStack{
                                Text("CKDQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.ckd.label))
                            }
                        })
                        NavigationLink(destination: UrgencyChoiceView(), label:{
                            HStack{
                                Text("UrgencydQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.isUrgent.label))
                            }
                        })
                        NavigationLink(destination: FeverChoiceView(), label:{
                            HStack{
                                Text("FeverQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.hasFever.label))
                            }
                        })
                        NavigationLink(destination: WBCChoiceView(), label:{
                            HStack{
                                Text("WBCQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.hasAbnormalWBC.label))
                            }
                        })
                        NavigationLink(destination: LocalInfectionChoiceView(), label:{
                            HStack{
                                Text("LocalInfectionQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.hasLocalInfection.label))
                            }
                        })
                        NavigationLink(destination: RutherfordClassChoiceView(), label:{
                            HStack{
                                Text("RutherfordClassQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.rutherford.label))
                            }
                        })
                    }
                    Section(header: Text("LesionInfo")){
                        NavigationLink(destination: AILesionChoiceView(), label:{
                            HStack{
                                Text("AILesionQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.hasAILesion.label))
                            }
                        })
                        NavigationLink(destination: FPLesionChoiceView(), label:{
                            HStack{
                                Text("FPLesionQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.hasFPLesion.label))
                            }
                        })
                        NavigationLink(destination: BKLesionChoiceView(), label:{
                            HStack{
                                Text("BKLesionQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.hasBKLesion.label))
                            }
                        })
                    }
                    Section(header: Text("OtherLesionInfo")){
                        NavigationLink(destination: ContralateralChoiceView(), label:{
                            HStack{
                                Text("ContralateralQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.hasContraLateralLesion.label))
                            }
                        })
                        NavigationLink(destination: OtherVDChoiceView(), label:{
                            HStack{
                                Text("OtherVDQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.hasOtherVD.label))
                            }
                        })
                    }
                    Section(header: Text("Complications")){
                        NavigationLink(destination: CHFChoiceView(), label:{
                            HStack{
                                Text("CHFQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.hasCHF.label))
                            }
                        })
                        NavigationLink(destination: CADChoiceView(), label:{
                            HStack{
                                Text("CADQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.hasCAD.label))
                            }
                        })
                        NavigationLink(destination: CVDChoiceView(), label:{
                            HStack{
                                Text("CVDQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.hasCVD.label))
                            }
                        })
                        NavigationLink(destination: DLChoiceView(), label:{
                            HStack{
                                Text("DLQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.hasDyslipidemia.label))
                            }
                        })
                        NavigationLink(destination: MalignancyChoiceView(), label:{
                            HStack{
                                Text("MalignancyQuestionTitle")
                                Spacer()
                                Text(LocalizedStringKey(patientData.malignantNeoplasm.label))
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
                            riskCalculated = false
                            return
                        }
                        if (patientData.hasAILesion == false &&
                            patientData.hasFPLesion == false &&
                            patientData.hasBKLesion == false){
                            errorMessage = QuestionError.IrrelevantLesion.message
                            failure = true
                            riskCalculated = false
                            return
                        }
                        risk = PatientRisk(of:patientData)
                        if (risk!.gnri == nil ||
                            risk!.gnriRisk == nil ||
                            risk!.predicted2YOS == nil ||
                            risk!.predicted30DDeathOrAmputation == nil ||
                            risk!.predicted30DMALE == nil ||
                            risk!.predicted2YOSRisk == nil ||
                            risk!.predicted2YAFS == nil){
                            riskCalculated = false
                            failure = true
                            return
                        }
                        riskCalculated = true
                        failure = false
                        
                    }.alert("ErrorTitle", isPresented: $failure){
                        
                    } message: {
                        Text(LocalizedStringKey(errorMessage))
                    }.accentColor(.teal)
                    Button("RESET"){
                        patientData.clear()
                    }.accentColor(.red)
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
                NavigationLink(destination: PredictedRiskView(risk: risk), isActive: $riskCalculated){
                    EmptyView()
                }
            }
            .listStyle(.insetGrouped)
            .accentColor(.teal)
        }
        
    }
}

struct RootContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootContentView().environmentObject(PatientData())
            .environment(\.locale, .init(identifier:"ja"))
    }
}
