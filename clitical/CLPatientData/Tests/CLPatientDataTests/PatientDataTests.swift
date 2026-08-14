import Foundation
import XCTest
@testable import CLPatientData

final class PatientDataTests: XCTestCase {
    func testInit() {
        let pd = PatientData()
        XCTAssertTrue(pd.sex == .female)
        XCTAssertTrue(pd.age == nil)
        XCTAssertTrue(pd.height == nil)
        XCTAssertTrue(pd.weight == nil)
        XCTAssertTrue(pd.alb == nil)
        XCTAssertTrue(pd.activity == .ambulatory)
        XCTAssertTrue(pd.hasCHF == false)
        XCTAssertTrue(pd.hasCAD == false)
        XCTAssertTrue(pd.hasCVD == false)
        XCTAssertTrue(pd.ckd == .normal)
        XCTAssertTrue(pd.malignantNeoplasm == .no)
        XCTAssertTrue(pd.hasAILesion == false)
        XCTAssertTrue(pd.hasFPLesion == false)
        XCTAssertTrue(pd.hasBKLesion == false)
        XCTAssertTrue(pd.isUrgent == false)
        XCTAssertTrue(pd.hasFever == false)
        XCTAssertTrue(pd.hasAbnormalWBC == false)
        XCTAssertTrue(pd.hasLocalInfection == false)
        XCTAssertTrue(pd.hasDyslipidemia == false)
        XCTAssertTrue(pd.isSmoking == false)
        XCTAssertTrue(pd.hasContraLateralLesion == false)
        XCTAssertTrue(pd.hasOtherVD == false)
        XCTAssertTrue(pd.rutherford == .class4)
    }

    func testValueSemantics() {
        var original = PatientData()
        original.age = 70
        var copy = original
        copy.age = 80
        XCTAssertTrue(original.age == 70)
        XCTAssertTrue(copy.age == 80)
    }

    func testClearResetsToInitialState() {
        var pd = PatientData()
        pd.age = 70
        pd.height = 160.0
        pd.hasCHF = true
        pd.clear()
        XCTAssertTrue(pd.age == nil)
        XCTAssertTrue(pd.height == nil)
        XCTAssertTrue(pd.hasCHF == false)
        XCTAssertTrue(pd.sex == .female)
    }
}
