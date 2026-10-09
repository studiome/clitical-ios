//
//  PatientRiskTest.swift
//
//
//  Created by kmiyahara on 2023/01/02.
//

import Foundation
import Testing
@testable import CLPatientData

@Suite
struct PatientRiskTests {
    @Test("Empty patient data yields no risk")
    func emptyDataYieldsNoRisk() {
        #expect(PatientRisk(patientData: PatientData()) == nil)
    }

    @Test("Zero height yields no risk")
    func zeroHeightYieldsNoRisk() {
        var pd = PatientData()
        pd.height = 0.0
        #expect(PatientRisk(patientData: pd) == nil)
    }

    @Test("Extremely low risk case")
    func extremelyLowRisk() throws {
        var pd = PatientData()
        // Sex has no default any more; these expectations were recorded for
        // a female patient.
        pd.sex = .female
        pd.age = 65
        pd.weight = 50.0
        pd.height = 150.0
        pd.alb = 4.0
        pd.hasAILesion = true

        let risk = try #require(PatientRisk(patientData: pd))
        let gnri = risk.gnri
        #expect(String(format: "%.1f", gnri) == "101.3")
        #expect(risk.gnriRisk == .noRisk)
        let p30DA = risk.predicted30DDeathOrAmputation
        #expect(String(format: "%.3f", p30DA) == "0.013")
        let p30DM = risk.predicted30DMALE
        #expect(String(format: "%.3f", p30DM) == "0.032")
        let p2YOS = risk.predicted2YOS
        #expect(String(format: "%.2f", p2YOS) == "0.92")
        #expect(risk.predicted2YOSRisk == .low)
        let p2YAFS = risk.predicted2YAFS
        #expect(String(format: "%.2f", p2YAFS) == "0.88")
    }

    /// Sex is a covariate of the regressions here, so an unanswered sex must
    /// leave the prediction unavailable rather than silently fall back to one
    /// of the two categories. The prediction is refused as a whole, even for
    /// the models (GNRI, 30-day death/amputation) that do not use sex.
    @Test("Unanswered sex refuses the whole prediction")
    func unansweredSexRefusesPrediction() {
        var pd = PatientData()
        pd.age = 70
        pd.height = 165.0
        pd.weight = 60.0
        pd.alb = 3.5
        pd.hasBKLesion = true

        #expect(PatientRisk(patientData: pd) == nil)
    }

    @Test("Low risk case")
    func lowRisk() throws {
        var pd = PatientData()
        pd.sex = .male
        pd.age = 50
        pd.weight = 60.0
        pd.height = 165.0
        pd.alb = 4.0
        pd.activity = .ambulatory
        pd.hasCHF = false
        pd.hasCAD = true
        pd.hasCVD = true
        pd.ckd = .g3
        pd.malignantNeoplasm = .no
        pd.hasAILesion = false
        pd.hasFPLesion = true
        pd.hasBKLesion = false
        pd.isUrgent = true
        pd.hasFever = true
        pd.hasAbnormalWBC = true
        pd.hasLocalInfection = true
        pd.hasDyslipidemia = false
        pd.isSmoking = true
        pd.hasContraLateralLesion = false
        pd.hasOtherVD = true
        pd.rutherford = .class4

        let risk = try #require(PatientRisk(patientData: pd))
        let gnri = risk.gnri
        #expect(String(format: "%.1f", gnri) == "101.3")
        #expect(risk.gnriRisk == .noRisk)
        let p30DA = risk.predicted30DDeathOrAmputation
        #expect(String(format: "%.3f", p30DA) == "0.088")
        let p30DM = risk.predicted30DMALE
        #expect(String(format: "%.3f", p30DM) == "0.152")
        let p2YOS = risk.predicted2YOS
        #expect(String(format: "%.2f", p2YOS) == "0.91")
        #expect(risk.predicted2YOSRisk == .low)
        let p2YAFS = risk.predicted2YAFS
        #expect(String(format: "%.2f", p2YAFS) == "0.64")
    }

    @Test("Medium risk case")
    func mediumRisk() throws {
        var pd = PatientData()
        pd.sex = .female
        pd.age = 70
        pd.weight = 55.0
        pd.height = 153.0
        pd.alb = 3.5
        pd.activity = .wheelchair
        pd.hasCHF = true
        pd.hasCAD = false
        pd.hasCVD = true
        pd.ckd = .g4
        pd.malignantNeoplasm = .pastHistory
        pd.hasAILesion = false
        pd.hasFPLesion = true
        pd.hasBKLesion = true
        pd.isUrgent = true
        pd.hasFever = true
        pd.hasAbnormalWBC = true
        pd.hasLocalInfection = true
        pd.hasDyslipidemia = true
        pd.isSmoking = false
        pd.hasContraLateralLesion = true
        pd.hasOtherVD = false
        pd.rutherford = .class5

        let risk = try #require(PatientRisk(patientData: pd))
        let gnri = risk.gnri
        #expect(String(format: "%.1f", gnri) == "93.8")
        #expect(risk.gnriRisk == .low)
        let p30DA = risk.predicted30DDeathOrAmputation
        #expect(String(format: "%.3f", p30DA) == "0.170")
        let p30DM = risk.predicted30DMALE
        #expect(String(format: "%.3f", p30DM) == "0.175")
        let p2YOS = risk.predicted2YOS
        #expect(String(format: "%.2f", p2YOS) == "0.67")
        #expect(risk.predicted2YOSRisk == .medium)
        let p2YAFS = risk.predicted2YAFS
        #expect(String(format: "%.2f", p2YAFS) == "0.25")
    }

    @Test("High risk case 1")
    func highRisk1() throws {
        var pd = PatientData()
        pd.sex = .male
        pd.age = 85
        pd.weight = 55.1
        pd.height = 175.0
        pd.alb = 3.5
        pd.activity = .immobile
        pd.hasCHF = false
        pd.hasCAD = true
        pd.hasCVD = false
        pd.ckd = .g5
        pd.malignantNeoplasm = .underTreatment
        pd.hasAILesion = false
        pd.hasFPLesion = false
        pd.hasBKLesion = true
        pd.isUrgent = true
        pd.hasFever = false
        pd.hasAbnormalWBC = true
        pd.hasLocalInfection = false
        pd.hasDyslipidemia = true
        pd.isSmoking = true
        pd.hasContraLateralLesion = true
        pd.hasOtherVD = false
        pd.rutherford = .class5

        let risk = try #require(PatientRisk(patientData: pd))
        let gnri = risk.gnri
        #expect(String(format: "%.1f", gnri) == "86.2")
        #expect(risk.gnriRisk == .moderate)
        let p30DA = risk.predicted30DDeathOrAmputation
        #expect(String(format: "%.3f", p30DA) == "0.100")
        let p30DM = risk.predicted30DMALE
        #expect(String(format: "%.3f", p30DM) == "0.043")
        let p2YOS = risk.predicted2YOS
        #expect(String(format: "%.2f", p2YOS) == "0.08")
        #expect(risk.predicted2YOSRisk == .high)
        let p2YAFS = risk.predicted2YAFS
        #expect(String(format: "%.2f", p2YAFS) == "0.03")
    }

    // Regression: isUrgent and hasAbnormalWBC must be counted independently.
    // Same base as testExtremelyLowRiskCase, with only isUrgent set.
    @Test("Urgent with normal WBC counts independently")
    func urgentWithNormalWBC() throws {
        var pd = PatientData()
        // Sex has no default any more; these expectations were recorded for
        // a female patient.
        pd.sex = .female
        pd.age = 65
        pd.weight = 50.0
        pd.height = 150.0
        pd.alb = 4.0
        pd.hasAILesion = true
        pd.isUrgent = true
        pd.hasAbnormalWBC = false

        let risk = try #require(PatientRisk(patientData: pd))
        let p30DA = risk.predicted30DDeathOrAmputation
        #expect(String(format: "%.3f", p30DA) == "0.024")
        let p30DM = risk.predicted30DMALE
        #expect(String(format: "%.3f", p30DM) == "0.040")
        let p2YOS = risk.predicted2YOS
        #expect(String(format: "%.2f", p2YOS) == "0.92")
        let p2YAFS = risk.predicted2YAFS
        #expect(String(format: "%.2f", p2YAFS) == "0.83")
    }

    // Same base, with only hasAbnormalWBC set.
    @Test("Abnormal WBC without urgency counts independently")
    func nonUrgentWithAbnormalWBC() throws {
        var pd = PatientData()
        // Sex has no default any more; these expectations were recorded for
        // a female patient.
        pd.sex = .female
        pd.age = 65
        pd.weight = 50.0
        pd.height = 150.0
        pd.alb = 4.0
        pd.hasAILesion = true
        pd.isUrgent = false
        pd.hasAbnormalWBC = true

        let risk = try #require(PatientRisk(patientData: pd))
        let p30DA = risk.predicted30DDeathOrAmputation
        #expect(String(format: "%.3f", p30DA) == "0.023")
        let p30DM = risk.predicted30DMALE
        #expect(String(format: "%.3f", p30DM) == "0.053")
        let p2YOS = risk.predicted2YOS
        #expect(String(format: "%.2f", p2YOS) == "0.92")
        let p2YAFS = risk.predicted2YAFS
        #expect(String(format: "%.2f", p2YAFS) == "0.85")
    }

    @Test("High risk case 2")
    func highRisk2() throws {
        var pd = PatientData()
        pd.sex = .female
        pd.age = 90
        pd.weight = 30.0
        pd.height = 155.0
        pd.alb = 3.2
        pd.activity = .immobile
        pd.hasCHF = true
        pd.hasCAD = true
        pd.hasCVD = true
        pd.ckd = .g5D
        pd.malignantNeoplasm = .underTreatment
        pd.hasAILesion = false
        pd.hasFPLesion = false
        pd.hasBKLesion = true
        pd.isUrgent = true
        pd.hasFever = true
        pd.hasAbnormalWBC = true
        pd.hasLocalInfection = true
        pd.hasDyslipidemia = true
        pd.isSmoking = true
        pd.hasContraLateralLesion = false
        pd.hasOtherVD = true
        pd.rutherford = .class6

        let risk = try #require(PatientRisk(patientData: pd))
        let gnri = risk.gnri
        #expect(String(format: "%.1f", gnri) == "71.3")
        #expect(risk.gnriRisk == .major)
        let p30DA = risk.predicted30DDeathOrAmputation
        #expect(String(format: "%.3f", p30DA) == "0.370")
        let p30DM = risk.predicted30DMALE
        #expect(String(format: "%.3f", p30DM) == "0.122")
        let p2YOS = risk.predicted2YOS
        #expect(String(format: "%.2f", p2YOS) == "0.00")
        #expect(risk.predicted2YOSRisk == .high)
        let p2YAFS = risk.predicted2YAFS
        #expect(String(format: "%.2f", p2YAFS) == "0.00")
    }
}
