//
//  ContentView.swift
//  clitical
//
//  Created by kmiyahara on 2022/12/20.
//

import SwiftUI
import CLPatientData

struct RootContentView: View {
    @EnvironmentObject var localization: LocalizationManager
    @State private var patientData = PatientData()
    @FocusState var isActive: Bool
    @State private var failure = false
    @State private var riskCalculated = false
    @State private var errorMessage = ""
    @State private var risk: PatientRisk?
    @State private var confirmingReset = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("BasicInfo")) {
                        AgeFormView(patientData: $patientData).focused($isActive)
                        SegmentedRow(title: "SexQuestionTitle",
                                  footer: "SexQuestionDescription",
                                  options: Sex.allCases,
                                  label: \.label,
                                  selection: $patientData.sex)
                        HeightFormView(patientData: $patientData).focused($isActive)
                        WeightFormView(patientData: $patientData).focused($isActive)
                    }
                    Section(header: Text("SocialHistory")) {
                        ToggleRow(title: "SmokingQuestionTitle",
                                  footer: "SmokingQuestionDescription",
                                  selection: $patientData.isSmoking)
                        MenuChoiceRow(title: "ActivityQuestionTitle",
                                  footer: "ActivityQuestionDescription",
                                  options: Activity.allCases,
                                  label: \.label,
                                  selection: $patientData.activity)
                    }
                    Section(header: Text("ClinicalInfo")) {
                        AlbFormView(patientData: $patientData).focused($isActive)
                        MenuChoiceRow(title: "CKDQuestionTitle",
                                  footer: "CKDQuestionDescription",
                                  options: CKD.allCases,
                                  label: \.label,
                                  selection: $patientData.ckd)
                        ToggleRow(title: "UrgencyQuestionTitle",
                                  footer: "UrgencyQuestionDescription",
                                  selection: $patientData.isUrgent)
                        ToggleRow(title: "FeverQuestionTitle",
                                  footer: "FeverQuestionDescription",
                                  selection: $patientData.hasFever)
                        ToggleRow(title: "WBCQuestionTitle",
                                  footer: "WBCQuestionDescription",
                                  selection: $patientData.hasAbnormalWBC)
                        ToggleRow(title: "LocalInfectionQuestionTitle",
                                  footer: "LocalInfectionQuestionDescription",
                                  selection: $patientData.hasLocalInfection)
                        MenuChoiceRow(title: "RutherfordClassQuestionTitle",
                                  footer: "RutherfordClassQuestionDescription",
                                  options: RutherfordClassification.allCases,
                                  label: \.label,
                                  selection: $patientData.rutherford)
                    }
                    Section(header: Text("LesionInfo")) {
                        ToggleRow(title: "AILesionQuestionTitle",
                                  footer: "AILesionQuestionDescription",
                                  selection: $patientData.hasAILesion)
                        ToggleRow(title: "FPLesionQuestionTitle",
                                  footer: "FPLesionQuestionDescription",
                                  selection: $patientData.hasFPLesion)
                        ToggleRow(title: "BKLesionQuestionTitle",
                                  footer: "BKLesionQuestionDescription",
                                  selection: $patientData.hasBKLesion)
                    }
                    Section(header: Text("OtherLesionInfo")) {
                        ToggleRow(title: "ContralateralQuestionTitle",
                                  footer: "ContralateralQuestionDescription",
                                  selection: $patientData.hasContraLateralLesion)
                        ToggleRow(title: "OtherVDQuestionTitle",
                                  footer: "OtherVDQuestionDescription",
                                  selection: $patientData.hasOtherVD)
                    }
                    Section(header: Text("Complications")) {
                        ToggleRow(title: "CHFQuestionTitle",
                                  footer: "CHFQuestionDescription",
                                  selection: $patientData.hasCHF)
                        ToggleRow(title: "CADQuestionTitle",
                                  footer: "CADQuestionDescription",
                                  selection: $patientData.hasCAD)
                        ToggleRow(title: "CVDQuestionTitle",
                                  footer: "CVDQuestionDescription",
                                  selection: $patientData.hasCVD)
                        ToggleRow(title: "DLQuestionTitle",
                                  footer: "DLQuestionDescription",
                                  selection: $patientData.hasDyslipidemia)
                        MenuChoiceRow(title: "MalignancyQuestionTitle",
                                  footer: "MalignancyQuestionDescription",
                                  options: MalignantNeoplasm.allCases,
                                  label: \.label,
                                  selection: $patientData.malignantNeoplasm)
                    }
                    Section {
                        Button("PredictRisks") {
                            predictRisks()
                        }
                        .alert("ErrorTitle", isPresented: $failure) {
                        } message: {
                            Text(LocalizedStringKey(errorMessage))
                        }
                        // Hidden programmatic-navigation link.  Attached as the
                        // button's background so it lives inside a list cell
                        // (measuring it outside one triggers the "Invalid frame
                        // dimension" runtime warning) without occupying a row of
                        // its own, which would leave a dangling separator and an
                        // empty sliver at the bottom of the section.
                        .background(
                            NavigationLink(destination: PredictedRiskView(risk: risk),
                                           isActive: $riskCalculated) {
                                EmptyView()
                            }
                            .opacity(0)
                        )
                        // Destructive role (not a bare red tint) so VoiceOver
                        // announces it as destructive, and a confirmation
                        // dialog because the wipe cannot be undone.
                        Button("RESET", role: .destructive) {
                            confirmingReset = true
                        }
                        .confirmationDialog("ResetConfirmationTitle",
                                            isPresented: $confirmingReset,
                                            titleVisibility: .visible) {
                            Button("RESET", role: .destructive) {
                                patientData.clear()
                            }
                            // Explicit cancel: the automatic one resolves its
                            // label through the overridden Bundle.main (see
                            // LocalizationManager) and comes out unlabeled,
                            // and this also keeps it in the app's language.
                            Button("CANCEL", role: .cancel) {}
                        }
                    }
                }
                .toolbar {
                    // A bare Spacer as a keyboard toolbar item makes SwiftUI log
                    // "Invalid frame dimension (negative or non-finite)"; laying
                    // out inside a single HStack item avoids it.
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            Spacer()
                            Button("DONE") {
                                isActive = false
                            }
                        }
                    }
                }
                .navigationTitle(Text(verbatim: localization.string(forKey: "PatientDataTitle")))
            }
            .listStyle(.insetGrouped)
        }
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
        failure = false
        // Deferred to the next run loop turn: if a keyboard dismissal or
        // other transition-coordinator transaction just completed, it may
        // not have settled yet. Flipping isActive synchronously in that
        // window can be silently dropped by SwiftUI's
        // NavigationLink(isActive:), so the push never happens.
        DispatchQueue.main.async {
            riskCalculated = true
        }
    }

    private func fail(with error: QuestionError) {
        errorMessage = error.message
        failure = true
        riskCalculated = false
    }
}

#Preview {
    RootContentView()
        .environmentObject(LocalizationManager())
        .environment(\.locale, .init(identifier: "ja"))
}
