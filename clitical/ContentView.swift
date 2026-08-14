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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var patientData = PatientData()
    @FocusState var isActive: Bool
    @State private var failure = false
    @State private var riskCalculated = false
    @State private var errorMessage = ""
    @State private var risk: PatientRisk?
    @State private var confirmingReset = false

    var body: some View {
        if horizontalSizeClass == .regular {
            regularBody
        } else {
            compactBody
        }
    }

    private var compactBody: some View {
        NavigationStack {
            List {
                patientDataSections
                actionSection
            }
            // iOS 16 caches LocalizedStringKey values inside List rows. Rebuild
            // only the list when the in-app language changes so section headers
            // re-resolve without discarding the parent view's patient data.
            .id(localization.language)
            .riskAssessmentListStyle()
            .keyboardDoneInset(isActive: isActive) {
                isActive = false
            }
            .navigationTitle(Text(verbatim: localization.string(forKey: "PatientDataTitle")))
            .navigationDestination(isPresented: $riskCalculated) {
                PredictedRiskView(risk: risk)
            }
        }
    }

    private var regularBody: some View {
        NavigationStack {
            HStack(spacing: 0) {
                List {
                    patientDataSections
                    actionSection
                }
                // Keep the same language-refresh behavior in the regular-width
                // layout while preserving RootContentView's state.
                .id(localization.language)
                .riskAssessmentListStyle()
                .frame(minWidth: 360, idealWidth: 480, maxWidth: 560)

                Divider()

                RiskPreviewPane(risk: risk)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color(.systemGroupedBackground))
            .keyboardDoneInset(isActive: isActive) {
                isActive = false
            }
            .navigationTitle(Text(verbatim: localization.string(forKey: "PatientDataTitle")))
        }
    }

    @ViewBuilder
    private var patientDataSections: some View {
        Section(header: localizedText("BasicInfo")) {
            AgeFormView(patientData: $patientData).focused($isActive)
            SegmentedRow(
                title: "SexQuestionTitle",
                options: Sex.allCases,
                label: \.label,
                selection: $patientData.sex)
            HeightFormView(patientData: $patientData).focused($isActive)
            WeightFormView(patientData: $patientData).focused($isActive)
        }
        Section(header: localizedText("SocialHistory")) {
            ToggleRow(
                title: "SmokingQuestionTitle",
                footer: "SmokingQuestionDescription",
                selection: $patientData.isSmoking)
            MenuChoiceRow(
                title: "ActivityQuestionTitle",
                options: Activity.allCases,
                label: \.label,
                selection: $patientData.activity)
        }
        Section(header: localizedText("ClinicalInfo")) {
            AlbFormView(patientData: $patientData).focused($isActive)
            MenuChoiceRow(
                title: "CKDQuestionTitle",
                footer: "CKDQuestionDescription",
                options: CKD.allCases,
                label: \.label,
                selection: $patientData.ckd)
            SegmentedRow(
                title: "UrgencyQuestionTitle",
                options: [true, false],
                label: { $0 ? "UrgencyUrgent" : "UrgencyElective" },
                selection: $patientData.isUrgent)
            ToggleRow(
                title: "FeverQuestionTitle",
                footer: "FeverQuestionDescription",
                selection: $patientData.hasFever)
            ToggleRow(
                title: "WBCQuestionTitle",
                footer: "WBCQuestionDescription",
                selection: $patientData.hasAbnormalWBC)
            ToggleRow(
                title: "LocalInfectionQuestionTitle",
                footer: "LocalInfectionQuestionDescription",
                selection: $patientData.hasLocalInfection)
            MenuChoiceRow(
                title: "RutherfordClassQuestionTitle",
                options: RutherfordClassification.allCases,
                label: \.label,
                selection: $patientData.rutherford)
        }
        Section(header: localizedText("LesionInfo")) {
            ToggleRow(
                title: "AILesionQuestionTitle",
                footer: "AILesionQuestionDescription",
                selection: $patientData.hasAILesion)
            ToggleRow(
                title: "FPLesionQuestionTitle",
                footer: "FPLesionQuestionDescription",
                selection: $patientData.hasFPLesion)
            ToggleRow(
                title: "BKLesionQuestionTitle",
                footer: "BKLesionQuestionDescription",
                selection: $patientData.hasBKLesion)
        }
        Section(header: localizedText("OtherLesionInfo")) {
            ToggleRow(
                title: "ContralateralQuestionTitle",
                footer: "ContralateralQuestionDescription",
                selection: $patientData.hasContraLateralLesion)
            ToggleRow(
                title: "OtherVDQuestionTitle",
                footer: "OtherVDQuestionDescription",
                selection: $patientData.hasOtherVD)
        }
        Section(header: localizedText("Complications")) {
            ToggleRow(
                title: "CHFQuestionTitle",
                footer: "CHFQuestionDescription",
                selection: $patientData.hasCHF)
            ToggleRow(
                title: "CADQuestionTitle",
                footer: "CADQuestionDescription",
                selection: $patientData.hasCAD)
            ToggleRow(
                title: "CVDQuestionTitle",
                footer: "CVDQuestionDescription",
                selection: $patientData.hasCVD)
            ToggleRow(
                title: "DLQuestionTitle",
                footer: "DLQuestionDescription",
                selection: $patientData.hasDyslipidemia)
            MenuChoiceRow(
                title: "MalignancyQuestionTitle",
                options: MalignantNeoplasm.allCases,
                label: \.label,
                selection: $patientData.malignantNeoplasm)
        }
    }

    private var actionSection: some View {
        Section {
            Button("PredictRisks") {
                predictRisks()
            }
            .alert("ErrorTitle", isPresented: $failure) {
            } message: {
                Text(LocalizedStringKey(errorMessage))
            }
            // Destructive role (not a bare red tint) so VoiceOver
            // announces it as destructive, and a confirmation
            // dialog because the wipe cannot be undone.
            Button("RESET", role: .destructive) {
                confirmingReset = true
            }
            .confirmationDialog(
                "ResetConfirmationTitle",
                isPresented: $confirmingReset,
                titleVisibility: .visible
            ) {
                Button("RESET", role: .destructive) {
                    patientData.clear()
                    risk = nil
                    riskCalculated = false
                }
                // Explicit cancel: the automatic one resolves its
                // label through the overridden Bundle.main (see
                // LocalizationManager) and comes out unlabeled,
                // and this also keeps it in the app's language.
                Button("CANCEL", role: .cancel) {}
            }
        }
    }

    private func predictRisks() {
        guard patientData.age != nil,
            patientData.height != nil,
            patientData.weight != nil,
            patientData.alb != nil
        else {
            fail(with: .numberFormIsNil)
            return
        }
        guard
            patientData.hasAILesion
                || patientData.hasFPLesion
                || patientData.hasBKLesion
        else {
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
            newRisk.predicted2YAFS != nil
        else {
            fail(with: .defaultError)
            return
        }
        risk = newRisk
        failure = false
        if horizontalSizeClass == .regular {
            riskCalculated = false
        } else {
            DispatchQueue.main.async {
                riskCalculated = true
            }
        }
    }

    private func fail(with error: QuestionError) {
        errorMessage = error.message
        failure = true
        riskCalculated = false
    }

    private func localizedText(_ key: String) -> Text {
        Text(verbatim: localization.string(forKey: key))
    }
}

private struct RiskPreviewPane: View {
    let risk: PatientRisk?

    var body: some View {
        Group {
            if risk != nil {
                PredictedRiskView(risk: risk, showsNavigationTitle: false)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                    Text("RiskPreviewEmptyTitle")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("RiskPreviewEmptyMessage")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 360)
                }
                .padding()
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func riskAssessmentListStyle() -> some View {
        if #available(iOS 17.0, *) {
            self
                .listStyle(.insetGrouped)
                .scrollDismissesKeyboard(.immediately)
                .contentMargins(.horizontal, 16, for: .scrollContent)
        } else {
            self
                .listStyle(.insetGrouped)
                .scrollDismissesKeyboard(.immediately)
        }
    }

    func keyboardDoneInset(isActive: Bool, dismiss: @escaping () -> Void) -> some View {
        safeAreaInset(edge: .bottom) {
            if isActive {
                HStack {
                    Spacer()
                    Button("KeyboardDone") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.bar)
            }
        }
    }
}

#Preview {
    RootContentView()
        .environmentObject(LocalizationManager())
        .environment(\.locale, .init(identifier: "ja"))
}
