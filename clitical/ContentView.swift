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
    @State private var failure = false
    @State private var riskCalculated = false
    @State private var errorMessage = ""
    @State private var risk: PatientRisk?

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("BasicInfo")) {
                        AgeFormView().focused($isActive)
                        ChoiceRow(title: "SexQuestionTitle",
                                  footer: "SexQuestionDescription",
                                  options: Sex.allCases,
                                  label: \.label,
                                  selection: $patientData.sex)
                        HeightFormView().focused($isActive)
                        WeightFormView().focused($isActive)
                    }
                    Section(header: Text("SocialHistory")) {
                        ChoiceRow(title: "SmokingQuestionTitle",
                                  footer: "SmokingQuestionDescription",
                                  selection: $patientData.isSmoking)
                        ChoiceRow(title: "ActivityQuestionTitle",
                                  footer: "ActivityQuestionDescription",
                                  options: Activity.allCases,
                                  label: \.label,
                                  selection: $patientData.activity)
                    }
                    Section(header: Text("ClinicalInfo")) {
                        AlbFormView().focused($isActive)
                        ChoiceRow(title: "CKDQuestionTitle",
                                  footer: "CKDQuestionDescription",
                                  options: CKD.allCases,
                                  label: \.label,
                                  selection: $patientData.ckd)
                        ChoiceRow(title: "UrgencyQuestionTitle",
                                  footer: "UrgencyQuestionDescription",
                                  selection: $patientData.isUrgent)
                        ChoiceRow(title: "FeverQuestionTitle",
                                  footer: "FeverQuestionDescription",
                                  selection: $patientData.hasFever)
                        ChoiceRow(title: "WBCQuestionTitle",
                                  footer: "WBCQuestionDescription",
                                  selection: $patientData.hasAbnormalWBC)
                        ChoiceRow(title: "LocalInfectionQuestionTitle",
                                  footer: "LocalInfectionQuestionDescription",
                                  selection: $patientData.hasLocalInfection)
                        ChoiceRow(title: "RutherfordClassQuestionTitle",
                                  footer: "RutherfordClassQuestionDescription",
                                  options: RutherfordClassification.allCases,
                                  label: \.label,
                                  selection: $patientData.rutherford)
                    }
                    Section(header: Text("LesionInfo")) {
                        ChoiceRow(title: "AILesionQuestionTitle",
                                  footer: "AILesionQuestionDescription",
                                  selection: $patientData.hasAILesion)
                        ChoiceRow(title: "FPLesionQuestionTitle",
                                  footer: "FPLesionQuestionDescription",
                                  selection: $patientData.hasFPLesion)
                        ChoiceRow(title: "BKLesionQuestionTitle",
                                  footer: "BKLesionQuestionDescription",
                                  selection: $patientData.hasBKLesion)
                    }
                    Section(header: Text("OtherLesionInfo")) {
                        ChoiceRow(title: "ContralateralQuestionTitle",
                                  footer: "ContralateralQuestionDescription",
                                  selection: $patientData.hasContraLateralLesion)
                        ChoiceRow(title: "OtherVDQuestionTitle",
                                  footer: "OtherVDQuestionDescription",
                                  selection: $patientData.hasOtherVD)
                    }
                    Section(header: Text("Complications")) {
                        ChoiceRow(title: "CHFQuestionTitle",
                                  footer: "CHFQuestionDescription",
                                  selection: $patientData.hasCHF)
                        ChoiceRow(title: "CADQuestionTitle",
                                  footer: "CADQuestionDescription",
                                  selection: $patientData.hasCAD)
                        ChoiceRow(title: "CVDQuestionTitle",
                                  footer: "CVDQuestionDescription",
                                  selection: $patientData.hasCVD)
                        ChoiceRow(title: "DLQuestionTitle",
                                  footer: "DLQuestionDescription",
                                  selection: $patientData.hasDyslipidemia)
                        ChoiceRow(title: "MalignancyQuestionTitle",
                                  footer: "MalignancyQuestionDescription",
                                  options: MalignantNeoplasm.allCases,
                                  label: \.label,
                                  selection: $patientData.malignantNeoplasm)
                    }
                    Button("PredictRisks") {
                        predictRisks()
                    }
                    .alert("ErrorTitle", isPresented: $failure) {
                    } message: {
                        Text(LocalizedStringKey(errorMessage))
                    }
                    .tint(.teal)
                    Button("RESET") {
                        patientData.clear()
                    }
                    .tint(.red)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("DONE") {
                            isActive = false
                        }
                    }
                }
                .navigationTitle("PatientDataTitle")
                NavigationLink(destination: PredictedRiskView(risk: risk),
                               isActive: $riskCalculated) {
                    EmptyView()
                }
            }
            .listStyle(.insetGrouped)
        }
        .tint(.teal)
    }

    private func predictRisks() {
        guard patientData.age != nil,
              patientData.height != nil,
              patientData.weight != nil,
              patientData.alb != nil else {
            fail(with: .numberFormIsNil)
            return
        }
        guard patientData.hasAILesion
                || patientData.hasFPLesion
                || patientData.hasBKLesion else {
            fail(with: .irrelevantLesion)
            return
        }
        let newRisk = PatientRisk(of: patientData)
        guard newRisk.gnri != nil,
              newRisk.gnriRisk != nil,
              newRisk.predicted2YOS != nil,
              newRisk.predicted30DDeathOrAmputation != nil,
              newRisk.predicted30DMALE != nil,
              newRisk.predicted2YOSRisk != nil,
              newRisk.predicted2YAFS != nil else {
            fail(with: .defaultError)
            return
        }
        risk = newRisk
        riskCalculated = true
        failure = false
    }

    private func fail(with error: QuestionError) {
        errorMessage = error.message
        failure = true
        riskCalculated = false
    }
}

#Preview {
    RootContentView()
        .environmentObject(PatientData())
        .environment(\.locale, .init(identifier: "ja"))
}
