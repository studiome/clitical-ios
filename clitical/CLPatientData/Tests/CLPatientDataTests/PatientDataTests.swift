import XCTest
@testable import CLPatientData
@available(macOS 10.15, *)
@available(iOS 13.0, *)

final class PatientDataTests: XCTestCase {
    func testInit() throws {
        let pd = PatientData();
        XCTAssertEqual(pd.sex, .female);
        XCTAssertNil(pd.age);
        XCTAssertNil(pd.height);
        XCTAssertNil(pd.weight);
        XCTAssertNil(pd.alb);
        XCTAssertEqual(pd.activity, .ambulatory);
        XCTAssertFalse(pd.hasCHF);
        XCTAssertFalse(pd.hasCAD);
        XCTAssertFalse(pd.hasCVD);
        XCTAssertEqual(pd.ckd,.normal);
        XCTAssertEqual(pd.malignantNeoplasm, .no);
        XCTAssertFalse(pd.hasAILesion);
        XCTAssertFalse(pd.hasFPLesion);
        XCTAssertFalse(pd.hasBKLesion);
        XCTAssertFalse(pd.isUrgent);
        XCTAssertFalse(pd.hasFever);
        XCTAssertFalse(pd.hasAbnormalWBC);
        XCTAssertFalse(pd.hasLocalInfection);
        XCTAssertFalse(pd.hasDyslipidemia);
        XCTAssertFalse(pd.isSmoking);
        XCTAssertFalse(pd.hasContraLateralLesion);
        XCTAssertFalse(pd.hasOtherVD);
        XCTAssertEqual(pd.rutherford, .class4);
    }
}
