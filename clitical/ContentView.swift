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
    @State private var predictionRequestID = UUID()

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                regularBody
            } else {
                compactBody
            }
        }
        .onChange(of: patientData) { _ in
            invalidatePrediction()
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
            .accessibilityIdentifier("patientDataList")
            .riskAssessmentListStyle()
            .keyboardDismissButton(isActive: isActive) {
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
                .accessibilityIdentifier("patientDataList")
                .riskAssessmentListStyle()
                .frame(minWidth: 360, idealWidth: 480, maxWidth: 560)

                Divider()

                RiskPreviewPane(risk: risk)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color(.systemGroupedBackground))
            .keyboardDismissButton(isActive: isActive) {
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
                // The hint appears only while the question is unanswered, so
                // a required field that was skipped is visible on the form
                // rather than only in the alert after tapping Predict.
                footer: patientData.sex == nil ? "SexRequiredHint" : nil,
                options: Sex.allCases.map(Optional.init),
                label: { $0?.label ?? "" },
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
                selection: $patientData.hasAILesion)
            ToggleRow(
                title: "FPLesionQuestionTitle",
                selection: $patientData.hasFPLesion)
            ToggleRow(
                title: "BKLesionQuestionTitle",
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
                    .frame(maxWidth: .infinity, minHeight: 28.0)
                    .foregroundStyle(Color.prominentButtonLabel)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("predictRisks")
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            .listRowBackground(Color.clear)
            .alert("ErrorTitle", isPresented: $failure) {
            } message: {
                // Already resolved against the current language, and may carry
                // a formatted range, so it is not a localization key.
                Text(verbatim: errorMessage)
            }
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
                    invalidatePrediction()
                }
                // Explicit cancel: the automatic one resolves its
                // label through the overridden Bundle.main (see
                // LocalizationManager) and comes out unlabeled,
                // and this also keeps it in the app's language.
                Button("CANCEL", role: .cancel) {}
                    .accessibilityIdentifier("resetConfirmationCancel")
            }
        }
    }

    private func predictRisks() {
        // Range checks matter as much as presence checks here: a height typed
        // in metres produces a perfectly plausible looking risk otherwise.
        if let error = patientData.validate() {
            fail(with: error.message(using: localization))
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
            fail(with: localization.string(forKey: "DefaultError"))
            return
        }
        risk = newRisk
        failure = false
        if horizontalSizeClass == .regular {
            riskCalculated = false
        } else {
            let requestID = UUID()
            predictionRequestID = requestID
            DispatchQueue.main.async {
                guard predictionRequestID == requestID, risk != nil else { return }
                riskCalculated = true
            }
        }
    }

    private func fail(with message: String) {
        predictionRequestID = UUID()
        errorMessage = message
        failure = true
        riskCalculated = false
    }

    private func invalidatePrediction() {
        predictionRequestID = UUID()
        risk = nil
        riskCalculated = false
    }

    private func localizedText(_ key: String) -> Text {
        Text(verbatim: localization.string(forKey: key))
    }
}

// These literal localizable API calls ensure Xcode includes the dynamically
// resolved section-header keys when exporting localization catalogs.
private enum SectionHeaderLocalizationKeys {
    static let basicInfo = String(localized: "BasicInfo")
    static let socialHistory = String(localized: "SocialHistory")
    static let clinicalInfo = String(localized: "ClinicalInfo")
    static let lesionInfo = String(localized: "LesionInfo")
    static let otherLesionInfo = String(localized: "OtherLesionInfo")
    static let complications = String(localized: "Complications")
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

    /// Places a keyboard-dismiss button in the navigation bar. Keeping it out
    /// of the keyboard accessory layout avoids transient negative frames while
    /// SwiftUI is presenting or dismissing a numeric keyboard on iOS 26.
    ///
    /// This replaces both the old dynamic `safeAreaInset` and keyboard
    /// accessory item. Both participate in the keyboard's transient layout;
    /// on iOS 26 that could publish a negative frame during focus changes.
    /// A navigation-bar item remains available without changing keyboard
    /// geometry, and avoids the resulting XCUITest runtime issue.
    func keyboardDismissButton(
        isActive: Bool,
        dismiss: @escaping () -> Void
    ) -> some View {
        toolbar {
            if isActive {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                    .accessibilityLabel(Text("DismissKeyboard"))
                    .accessibilityIdentifier("dismissKeyboard")
                }
            }
        }
    }
}

#Preview {
    RootContentView()
        .environmentObject(LocalizationManager())
        .environment(\.locale, .init(identifier: "ja"))
}
