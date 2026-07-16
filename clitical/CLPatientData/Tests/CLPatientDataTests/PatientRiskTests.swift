//
//  PatientRiskTest.swift
//  
//
//  Created by kmiyahara on 2023/01/02.
//

import XCTest
@testable import CLPatientData

final class PatientRiskTests: XCTestCase {
    
    func testInit() throws {
        let pd = PatientData()
        let risk = PatientRisk(of: pd)
        XCTAssertNil(risk.gnri)
        XCTAssertNil(risk.gnriRisk)
        XCTAssertNil(risk.predicted30DDeathOrAmputation)
        XCTAssertNil(risk.predicted30DMALE)
        XCTAssertNil(risk.predicted2YOS)
        XCTAssertNil(risk.predicted2YOSRisk)
        XCTAssertNil(risk.predicted2YAFS)
    }
    
    func testErrorCase() throws{
        var pd = PatientData()
        pd.height = 0.0
        let risk = PatientRisk(of: pd)
        XCTAssertNil(risk.gnri)
        XCTAssertNil(risk.gnriRisk)
        XCTAssertNil(risk.predicted30DDeathOrAmputation)
        XCTAssertNil(risk.predicted30DMALE)
        XCTAssertNil(risk.predicted2YOS)
        XCTAssertNil(risk.predicted2YOSRisk)
        XCTAssertNil(risk.predicted2YAFS)
    }
    
    func testExtremelyLowRiskCase() throws{
        var pd = PatientData()
        pd.age = 65
        pd.weight = 50.0
        pd.height = 150.0
        pd.alb = 4.0
        pd.hasAILesion = true
        //Others are all false
        
        let risk = PatientRisk(of: pd)
        XCTAssertEqual(String(format: "%.1f", risk.gnri!), "101.3")
        XCTAssertEqual(risk.gnriRisk, .noRisk)
        XCTAssertEqual(String(format: "%.3f", risk.predicted30DDeathOrAmputation!), "0.013")
        XCTAssertEqual(String(format: "%.3f", risk.predicted30DMALE!), "0.032")
        XCTAssertEqual(String(format: "%.2f", risk.predicted2YOS!), "0.92")
        XCTAssertEqual(risk.predicted2YOSRisk, .low)
        XCTAssertEqual(String(format: "%.2f", risk.predicted2YAFS!), "0.88")
    }
    
    func testLowRiskCase() throws{
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
        XCTAssertEqual(String(format: "%.1f", risk.gnri!), "101.3")
        XCTAssertEqual(risk.gnriRisk, .noRisk)
        XCTAssertEqual(String(format: "%.3f", risk.predicted30DDeathOrAmputation!), "0.088")
        XCTAssertEqual(String(format: "%.3f", risk.predicted30DMALE!), "0.152")
        XCTAssertEqual(String(format: "%.2f", risk.predicted2YOS!), "0.91")
        XCTAssertEqual(risk.predicted2YOSRisk!, .low)
        XCTAssertEqual(String(format: "%.2f", risk.predicted2YAFS!), "0.64")
    }
    
    func testMediumRiskCase() throws{
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
        XCTAssertEqual(String(format: "%.1f", risk.gnri!), "93.8")
        XCTAssertEqual(risk.gnriRisk, .low)
        XCTAssertEqual(String(format: "%.3f", risk.predicted30DDeathOrAmputation!), "0.170")
        XCTAssertEqual(String(format: "%.3f", risk.predicted30DMALE!), "0.175")
        XCTAssertEqual(String(format: "%.2f", risk.predicted2YOS!), "0.67")
        XCTAssertEqual(risk.predicted2YOSRisk!, .medium)
        XCTAssertEqual(String(format: "%.2f", risk.predicted2YAFS!), "0.25")
    }
    
    func testHighRiskCase1() throws{
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
        XCTAssertEqual(String(format: "%.1f", risk.gnri!), "86.2")
        XCTAssertEqual(risk.gnriRisk!, .moderate)
        XCTAssertEqual(String(format: "%.3f", risk.predicted30DDeathOrAmputation!), "0.100")
        XCTAssertEqual(String(format: "%.3f", risk.predicted30DMALE!), "0.043")
        XCTAssertEqual(String(format: "%.2f", risk.predicted2YOS!), "0.08")
        XCTAssertEqual(risk.predicted2YOSRisk!, .high)
        XCTAssertEqual(String(format: "%.2f", risk.predicted2YAFS!), "0.03")
    }
    
    // Regression: isUrgent and hasAbnormalWBC must be counted independently.
    // Same base as testExtremelyLowRiskCase, with only isUrgent set.
    func testUrgentWithNormalWBC() throws{
        var pd = PatientData()
        pd.age = 65
        pd.weight = 50.0
        pd.height = 150.0
        pd.alb = 4.0
        pd.hasAILesion = true
        pd.isUrgent = true
        pd.hasAbnormalWBC = false

        let risk = PatientRisk(of: pd)
        XCTAssertEqual(String(format: "%.3f", risk.predicted30DDeathOrAmputation!), "0.024")
        XCTAssertEqual(String(format: "%.3f", risk.predicted30DMALE!), "0.040")
        XCTAssertEqual(String(format: "%.2f", risk.predicted2YOS!), "0.92")
        XCTAssertEqual(String(format: "%.2f", risk.predicted2YAFS!), "0.83")
    }

    // Same base, with only hasAbnormalWBC set.
    func testNonUrgentWithAbnormalWBC() throws{
        var pd = PatientData()
        pd.age = 65
        pd.weight = 50.0
        pd.height = 150.0
        pd.alb = 4.0
        pd.hasAILesion = true
        pd.isUrgent = false
        pd.hasAbnormalWBC = true

        let risk = PatientRisk(of: pd)
        XCTAssertEqual(String(format: "%.3f", risk.predicted30DDeathOrAmputation!), "0.023")
        XCTAssertEqual(String(format: "%.3f", risk.predicted30DMALE!), "0.053")
        XCTAssertEqual(String(format: "%.2f", risk.predicted2YOS!), "0.92")
        XCTAssertEqual(String(format: "%.2f", risk.predicted2YAFS!), "0.85")
    }

    func testHighRiskCase2() throws{
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
        XCTAssertEqual(String(format: "%.1f", risk.gnri!), "71.3")
        XCTAssertEqual(risk.gnriRisk!, .major)
        XCTAssertEqual(String(format: "%.3f", risk.predicted30DDeathOrAmputation!), "0.370")
        XCTAssertEqual(String(format: "%.3f", risk.predicted30DMALE!), "0.122")
        XCTAssertEqual(String(format: "%.2f", risk.predicted2YOS!), "0.00")
        XCTAssertEqual(risk.predicted2YOSRisk!, .high)
        XCTAssertEqual(String(format: "%.2f", risk.predicted2YAFS!), "0.00")
    }
}
