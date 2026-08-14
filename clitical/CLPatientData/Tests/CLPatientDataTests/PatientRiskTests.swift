//
//  PatientRiskTest.swift
//
//
//  Created by kmiyahara on 2023/01/02.
//

import Foundation
import XCTest
@testable import CLPatientData

final class PatientRiskTests: XCTestCase {
    func testInit() {
        let pd = PatientData()
        let risk = PatientRisk(of: pd)
        XCTAssertTrue(risk.gnri == nil)
        XCTAssertTrue(risk.gnriRisk == nil)
        XCTAssertTrue(risk.predicted30DDeathOrAmputation == nil)
        XCTAssertTrue(risk.predicted30DMALE == nil)
        XCTAssertTrue(risk.predicted2YOS == nil)
        XCTAssertTrue(risk.predicted2YOSRisk == nil)
        XCTAssertTrue(risk.predicted2YAFS == nil)
    }

    func testErrorCase() {
        var pd = PatientData()
        pd.height = 0.0
        let risk = PatientRisk(of: pd)
        XCTAssertTrue(risk.gnri == nil)
        XCTAssertTrue(risk.gnriRisk == nil)
        XCTAssertTrue(risk.predicted30DDeathOrAmputation == nil)
        XCTAssertTrue(risk.predicted30DMALE == nil)
        XCTAssertTrue(risk.predicted2YOS == nil)
        XCTAssertTrue(risk.predicted2YOSRisk == nil)
        XCTAssertTrue(risk.predicted2YAFS == nil)
    }

    func testExtremelyLowRiskCase() throws {
        var pd = PatientData()
        pd.age = 65
        pd.weight = 50.0
        pd.height = 150.0
        pd.alb = 4.0
        pd.hasAILesion = true

        let risk = PatientRisk(of: pd)
        let gnri = try XCTUnwrap(risk.gnri)
        XCTAssertTrue(String(format: "%.1f", gnri) == "101.3")
        XCTAssertTrue(risk.gnriRisk == .noRisk)
        let p30DA = try XCTUnwrap(risk.predicted30DDeathOrAmputation)
        XCTAssertTrue(String(format: "%.3f", p30DA) == "0.013")
        let p30DM = try XCTUnwrap(risk.predicted30DMALE)
        XCTAssertTrue(String(format: "%.3f", p30DM) == "0.032")
        let p2YOS = try XCTUnwrap(risk.predicted2YOS)
        XCTAssertTrue(String(format: "%.2f", p2YOS) == "0.92")
        XCTAssertTrue(risk.predicted2YOSRisk == .low)
        let p2YAFS = try XCTUnwrap(risk.predicted2YAFS)
        XCTAssertTrue(String(format: "%.2f", p2YAFS) == "0.88")
    }

    func testLowRiskCase() throws {
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

        let risk = PatientRisk(of: pd)
        let gnri = try XCTUnwrap(risk.gnri)
        XCTAssertTrue(String(format: "%.1f", gnri) == "101.3")
        XCTAssertTrue(risk.gnriRisk == .noRisk)
        let p30DA = try XCTUnwrap(risk.predicted30DDeathOrAmputation)
        XCTAssertTrue(String(format: "%.3f", p30DA) == "0.088")
        let p30DM = try XCTUnwrap(risk.predicted30DMALE)
        XCTAssertTrue(String(format: "%.3f", p30DM) == "0.152")
        let p2YOS = try XCTUnwrap(risk.predicted2YOS)
        XCTAssertTrue(String(format: "%.2f", p2YOS) == "0.91")
        XCTAssertTrue(risk.predicted2YOSRisk == .low)
        let p2YAFS = try XCTUnwrap(risk.predicted2YAFS)
        XCTAssertTrue(String(format: "%.2f", p2YAFS) == "0.64")
    }

    func testMediumRiskCase() throws {
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

        let risk = PatientRisk(of: pd)
        let gnri = try XCTUnwrap(risk.gnri)
        XCTAssertTrue(String(format: "%.1f", gnri) == "93.8")
        XCTAssertTrue(risk.gnriRisk == .low)
        let p30DA = try XCTUnwrap(risk.predicted30DDeathOrAmputation)
        XCTAssertTrue(String(format: "%.3f", p30DA) == "0.170")
        let p30DM = try XCTUnwrap(risk.predicted30DMALE)
        XCTAssertTrue(String(format: "%.3f", p30DM) == "0.175")
        let p2YOS = try XCTUnwrap(risk.predicted2YOS)
        XCTAssertTrue(String(format: "%.2f", p2YOS) == "0.67")
        XCTAssertTrue(risk.predicted2YOSRisk == .medium)
        let p2YAFS = try XCTUnwrap(risk.predicted2YAFS)
        XCTAssertTrue(String(format: "%.2f", p2YAFS) == "0.25")
    }

    func testHighRiskCase1() throws {
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

        let risk = PatientRisk(of: pd)
        let gnri = try XCTUnwrap(risk.gnri)
        XCTAssertTrue(String(format: "%.1f", gnri) == "86.2")
        XCTAssertTrue(risk.gnriRisk == .moderate)
        let p30DA = try XCTUnwrap(risk.predicted30DDeathOrAmputation)
        XCTAssertTrue(String(format: "%.3f", p30DA) == "0.100")
        let p30DM = try XCTUnwrap(risk.predicted30DMALE)
        XCTAssertTrue(String(format: "%.3f", p30DM) == "0.043")
        let p2YOS = try XCTUnwrap(risk.predicted2YOS)
        XCTAssertTrue(String(format: "%.2f", p2YOS) == "0.08")
        XCTAssertTrue(risk.predicted2YOSRisk == .high)
        let p2YAFS = try XCTUnwrap(risk.predicted2YAFS)
        XCTAssertTrue(String(format: "%.2f", p2YAFS) == "0.03")
    }

    // Regression: isUrgent and hasAbnormalWBC must be counted independently.
    // Same base as testExtremelyLowRiskCase, with only isUrgent set.
    func testUrgentWithNormalWBC() throws {
        var pd = PatientData()
        pd.age = 65
        pd.weight = 50.0
        pd.height = 150.0
        pd.alb = 4.0
        pd.hasAILesion = true
        pd.isUrgent = true
        pd.hasAbnormalWBC = false

        let risk = PatientRisk(of: pd)
        let p30DA = try XCTUnwrap(risk.predicted30DDeathOrAmputation)
        XCTAssertTrue(String(format: "%.3f", p30DA) == "0.024")
        let p30DM = try XCTUnwrap(risk.predicted30DMALE)
        XCTAssertTrue(String(format: "%.3f", p30DM) == "0.040")
        let p2YOS = try XCTUnwrap(risk.predicted2YOS)
        XCTAssertTrue(String(format: "%.2f", p2YOS) == "0.92")
        let p2YAFS = try XCTUnwrap(risk.predicted2YAFS)
        XCTAssertTrue(String(format: "%.2f", p2YAFS) == "0.83")
    }

    // Same base, with only hasAbnormalWBC set.
    func testNonUrgentWithAbnormalWBC() throws {
        var pd = PatientData()
        pd.age = 65
        pd.weight = 50.0
        pd.height = 150.0
        pd.alb = 4.0
        pd.hasAILesion = true
        pd.isUrgent = false
        pd.hasAbnormalWBC = true

        let risk = PatientRisk(of: pd)
        let p30DA = try XCTUnwrap(risk.predicted30DDeathOrAmputation)
        XCTAssertTrue(String(format: "%.3f", p30DA) == "0.023")
        let p30DM = try XCTUnwrap(risk.predicted30DMALE)
        XCTAssertTrue(String(format: "%.3f", p30DM) == "0.053")
        let p2YOS = try XCTUnwrap(risk.predicted2YOS)
        XCTAssertTrue(String(format: "%.2f", p2YOS) == "0.92")
        let p2YAFS = try XCTUnwrap(risk.predicted2YAFS)
        XCTAssertTrue(String(format: "%.2f", p2YAFS) == "0.85")
    }

    func testHighRiskCase2() throws {
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

        let risk = PatientRisk(of: pd)
        let gnri = try XCTUnwrap(risk.gnri)
        XCTAssertTrue(String(format: "%.1f", gnri) == "71.3")
        XCTAssertTrue(risk.gnriRisk == .major)
        let p30DA = try XCTUnwrap(risk.predicted30DDeathOrAmputation)
        XCTAssertTrue(String(format: "%.3f", p30DA) == "0.370")
        let p30DM = try XCTUnwrap(risk.predicted30DMALE)
        XCTAssertTrue(String(format: "%.3f", p30DM) == "0.122")
        let p2YOS = try XCTUnwrap(risk.predicted2YOS)
        XCTAssertTrue(String(format: "%.2f", p2YOS) == "0.00")
        XCTAssertTrue(risk.predicted2YOSRisk == .high)
        let p2YAFS = try XCTUnwrap(risk.predicted2YAFS)
        XCTAssertTrue(String(format: "%.2f", p2YAFS) == "0.00")
    }
}
