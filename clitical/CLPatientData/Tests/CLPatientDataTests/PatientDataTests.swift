import Foundation
import XCTest
@testable import CLPatientData

final class PatientDataTests: XCTestCase {
    func testInit() {
        let pd = PatientData()
        XCTAssertEqual(pd.sex, .female)
        XCTAssertNil(pd.age)
        XCTAssertNil(pd.height)
        XCTAssertNil(pd.weight)
        XCTAssertNil(pd.alb)
        XCTAssertEqual(pd.activity, .ambulatory)
        XCTAssertFalse(pd.hasCHF)
        XCTAssertFalse(pd.hasCAD)
        XCTAssertFalse(pd.hasCVD)
        XCTAssertEqual(pd.ckd, .normal)
        XCTAssertEqual(pd.malignantNeoplasm, .no)
        XCTAssertFalse(pd.hasAILesion)
        XCTAssertFalse(pd.hasFPLesion)
        XCTAssertFalse(pd.hasBKLesion)
        XCTAssertFalse(pd.isUrgent)
        XCTAssertFalse(pd.hasFever)
        XCTAssertFalse(pd.hasAbnormalWBC)
        XCTAssertFalse(pd.hasLocalInfection)
        XCTAssertFalse(pd.hasDyslipidemia)
        XCTAssertFalse(pd.isSmoking)
        XCTAssertFalse(pd.hasContraLateralLesion)
        XCTAssertFalse(pd.hasOtherVD)
        XCTAssertEqual(pd.rutherford, .class4)
    }

    func testValueSemantics() {
        var original = PatientData()
        original.age = 70
        var copy = original
        copy.age = 80
        XCTAssertEqual(original.age, 70)
        XCTAssertEqual(copy.age, 80)
    }

    func testClearResetsToInitialState() {
        var pd = PatientData()
        pd.age = 70
        pd.height = 160.0
        pd.hasCHF = true
        pd.clear()
        XCTAssertNil(pd.age)
        XCTAssertNil(pd.height)
        XCTAssertFalse(pd.hasCHF)
        XCTAssertEqual(pd.sex, .female)
    }
}
