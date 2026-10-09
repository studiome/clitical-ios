//
//  RootContentView.swift
//  clitical
//
//  Created by kmiyahara on 2022/12/20.
//

import SwiftUI
import CLPatientData

struct RootContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ScaledMetric(relativeTo: .headline) private var buttonMinHeight = 28.0
    @State private var patientData = PatientData()
    @FocusState private var isActive: Bool
    @State private var riskCalculated = false
    @State private var errorMessage: String?
    @State private var risk: PatientRisk?
    @State private var confirmingReset = false
    @State private var predictionRequestID = UUID()
    /// Set once a Predict attempt has failed validation, which is when empty
    /// required fields start to show their inline "required" hint.
    @State private var hasAttemptedPrediction = false

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                regularBody
            } else {
                compactBody
            }
        }
        .onChange(of: patientData) {
            invalidatePrediction()
        }
        // Attached here rather than to the Predict row: the toolbar button
        // can fire while that list row is off screen and not yet built.
        .alert("ErrorTitle", isPresented: isShowingError, presenting: errorMessage) { _ in
        } message: { message in
            // Already localized, and may carry a formatted range, so it
            // is not a localization key.
            Text(verbatim: message)
        }
    }

    private var compactBody: some View {
        NavigationStack {
            List {
                patientDataSections
                actionSection
            }
            .accessibilityIdentifier("patientDataList")
            .riskAssessmentListStyle()
            .keyboardDismissButton(isActive: isActive) {
                isActive = false
            }
            .predictRisksToolbarButton(predictRisks)
            .navigationTitle(Text("PatientDataTitle"))
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
                .accessibilityIdentifier("patientDataList")
                .riskAssessmentListStyle()
                .frame(minWidth: 320, idealWidth: 420, maxWidth: 520)

                Divider()

                RiskPreviewPane(risk: risk)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color(.systemGroupedBackground))
            .keyboardDismissButton(isActive: isActive) {
                isActive = false
            }
            .predictRisksToolbarButton(predictRisks)
            .navigationTitle(Text("PatientDataTitle"))
        }
    }

    @ViewBuilder
    private var patientDataSections: some View {
        Section(header: Text("BasicInfo")) {
            NumberFieldRow(title: "AgeQuestionTitle",
                           unit: "UnitYears",
                           example: "70",
                           value: $patientData.age,
                           keyboard: .numberPad,
                           errorMessage: inlineError(
                               isPresent: patientData.age != nil,
                               isInRange: patientData.age.map(PatientData.validAgeRange.contains) ?? true,
                               outOfRange: .ageOutOfRange),
                           errorIdentifier: "ageInlineError")
                .focused($isActive)
            SegmentedRow(
                title: "SexQuestionTitle",
                // The hint appears only while the question is unanswered, so
                // a required field that was skipped is visible on the form
                // rather than only in the alert after tapping Predict.
                footer: patientData.sex == nil ? "SexRequiredHint" : nil,
                options: Sex.allCases.map(Optional.init),
                label: { $0?.label ?? "" },
                selection: $patientData.sex)
            NumberFieldRow(title: "HeightQuestionTitle",
                           unit: "UnitCM",
                           example: "165",
                           value: $patientData.height,
                           keyboard: .decimalPad,
                           errorMessage: inlineError(
                               isPresent: patientData.height != nil,
                               isInRange: patientData.height.map(PatientData.validHeightRange.contains) ?? true,
                               outOfRange: .heightOutOfRange),
                           errorIdentifier: "heightInlineError")
                .focused($isActive)
            NumberFieldRow(title: "WeightQuestionTitle",
                           unit: "UnitKG",
                           example: "60",
                           value: $patientData.weight,
                           keyboard: .decimalPad,
                           errorMessage: inlineError(
                               isPresent: patientData.weight != nil,
                               isInRange: patientData.weight.map(PatientData.validWeightRange.contains) ?? true,
                               outOfRange: .weightOutOfRange),
                           errorIdentifier: "weightInlineError")
                .focused($isActive)
        }
        Section(header: Text("SocialHistory")) {
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
        Section(header: Text("ClinicalInfo")) {
            NumberFieldRow(title: "AlbQuestionTitle",
                           unit: "UnitGPerDL",
                           example: "3.5",
                           value: $patientData.alb,
                           keyboard: .decimalPad,
                           errorMessage: inlineError(
                               isPresent: patientData.alb != nil,
                               isInRange: patientData.alb.map(PatientData.validAlbuminRange.contains) ?? true,
                               outOfRange: .albuminOutOfRange),
                           errorIdentifier: "albuminInlineError")
                .focused($isActive)
            MenuChoiceRow(
                title: "CKDQuestionTitle",
                footer: "CKDQuestionDescription",
                options: CKD.allCases,
                label: \.label,
                selection: $patientData.ckd)
            SegmentedRow(
                title: "UrgencyQuestionTitle",
                options: [false, true],
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
        Section(header: Text("LesionInfo"), footer: lesionFooter) {
            ToggleRow(
                title: "AILesionQuestionTitle",
                selection: $patientData.hasAILesion)
            ToggleRow(
                title: "FPLesionQuestionTitle",
                selection: $patientData.hasFPLesion)
            ToggleRow(
                title: "BKLesionQuestionTitle",
                selection: $patientData.hasBKLesion)
        }
        Section(header: Text("OtherLesionInfo")) {
            ToggleRow(
                title: "ContralateralQuestionTitle",
                footer: "ContralateralQuestionDescription",
                selection: $patientData.hasContraLateralLesion)
            ToggleRow(
                title: "OtherVDQuestionTitle",
                footer: "OtherVDQuestionDescription",
                selection: $patientData.hasOtherVD)
        }
        Section(header: Text("Complications")) {
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

    /// The primary action, styled prominently per HIG so it reads as the
    /// call to action rather than as one more list row.
    @ViewBuilder
    private var actionSection: some View {
        Section {
            Button {
                predictRisks()
            } label: {
                Text("PredictRisks")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: buttonMinHeight)
                    .foregroundStyle(Color.prominentButtonLabel)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("predictRisks")
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            .listRowBackground(Color.clear)
        }
        // Reset sits in its own section: a destructive action directly below
        // the primary one invites mistaps.
        Section {
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
                    hasAttemptedPrediction = false
                    invalidatePrediction()
                }
                // Explicit cancel: the automatic one has come out
                // unlabeled in this dialog, so the button is spelled out.
                Button("CANCEL", role: .cancel) {}
                    .accessibilityIdentifier("resetConfirmationCancel")
            }
        }
    }

    private var isShowingError: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private func predictRisks() {
        // The toolbar button can be tapped while a number pad is up; close it
        // so the alert or the results are not presented under the keyboard.
        isActive = false
        // Range checks matter as much as presence checks here: a height typed
        // in metres produces a perfectly plausible looking risk otherwise.
        if let error = patientData.validate() {
            fail(with: error.message)
            return
        }
        guard let newRisk = PatientRisk(patientData: patientData) else {
            fail(with: String(localized: "DefaultError"))
            return
        }
        risk = newRisk
        errorMessage = nil
        if horizontalSizeClass == .regular {
            riskCalculated = false
        } else {
            let requestID = UUID()
            predictionRequestID = requestID
            Task { @MainActor in
                guard predictionRequestID == requestID, risk != nil else { return }
                riskCalculated = true
            }
        }
    }

    private func fail(with message: String) {
        hasAttemptedPrediction = true
        predictionRequestID = UUID()
        errorMessage = message
        riskCalculated = false
    }

    private func invalidatePrediction() {
        predictionRequestID = UUID()
        risk = nil
        riskCalculated = false
    }

    /// The inline message for a number field: an out-of-range value is
    /// flagged as soon as it is entered; an empty one only after a Predict
    /// attempt has failed, so a fresh form is not covered in errors.
    private func inlineError(
        isPresent: Bool,
        isInRange: Bool,
        outOfRange: PatientDataValidationError
    ) -> String? {
        if isPresent {
            return isInRange ? nil : outOfRange.message
        }
        return hasAttemptedPrediction ? String(localized: "RequiredFieldHint") : nil
    }

    /// Explains the lesion section only once Predict has failed for want of a
    /// lesion; before that the section is unremarkable.
    @ViewBuilder
    private var lesionFooter: some View {
        if hasAttemptedPrediction && !patientData.hasAILesion
            && !patientData.hasFPLesion && !patientData.hasBKLesion {
            InlineErrorLabel(message: PatientDataValidationError.noLesionSelected.message,
                             identifier: "lesionInlineError")
        }
    }
}

private struct RiskPreviewPane: View {
    let risk: PatientRisk?

    var body: some View {
        Group {
            if let risk {
                PredictedRiskView(risk: risk, showsNavigationTitle: false)
            } else {
                ContentUnavailableView {
                    Label("RiskPreviewEmptyTitle", systemImage: "chart.line.uptrend.xyaxis")
                } description: {
                    Text("RiskPreviewEmptyMessage")
                }
            }
        }
    }
}

private extension View {
    func riskAssessmentListStyle() -> some View {
        self
            .listStyle(.insetGrouped)
            .scrollDismissesKeyboard(.immediately)
            .contentMargins(.horizontal, 16, for: .scrollContent)
    }

    /// Places a keyboard-dismiss button at the leading side of the navigation
    /// bar (the primary action, Predict, takes the trailing side).
    ///
    /// The HIG-standard placement is a "Done" item in a `.keyboard` toolbar.
    /// That is deliberately not used yet: the keyboard accessory (and the old
    /// dynamic `safeAreaInset`) participate in the keyboard's transient
    /// layout, and on iOS 26 that could publish a negative frame during focus
    /// changes, which also broke XCUITest. A navigation-bar item leaves the
    /// keyboard geometry alone. Move it back to `.keyboard` once the iOS 26
    /// negative-frame issue is fixed.
    func keyboardDismissButton(
        isActive: Bool,
        dismiss: @escaping () -> Void
    ) -> some View {
        toolbar {
            if isActive {
                ToolbarItem(placement: .topBarLeading) {
                    keyboardDismissLabel(dismiss)
                }
            }
        }
    }

    private func keyboardDismissLabel(_ dismiss: @escaping () -> Void) -> some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "keyboard.chevron.compact.down")
        }
        .accessibilityLabel(Text("DismissKeyboard"))
        .accessibilityIdentifier("dismissKeyboard")
    }

    /// The primary action in the navigation bar, so the form's main button is
    /// reachable without scrolling to the bottom of the long list.
    func predictRisksToolbarButton(_ action: @escaping () -> Void) -> some View {
        toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("PredictRisks", action: action)
                    .accessibilityIdentifier("predictRisksToolbar")
            }
        }
    }
}

#Preview {
    RootContentView()
        .environment(\.locale, .init(identifier: "ja"))
}
