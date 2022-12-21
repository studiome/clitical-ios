import XCTest
@testable import CLPatientData

final class CLPatientDataTests: XCTestCase {
    func testInit() throws {
        let pd = CLPatientData();
        XCTAssertEqual(pd.sex, Sex.Female);
        XCTAssertNil(pd.age);
        XCTAssertNil(pd.height);
        XCTAssertNil(pd.weight);
        XCTAssertNil(pd.alb);
        XCTAssertEqual(pd.activity, Activity.Ambulatory);
        XCTAssertFalse(pd.hasCHF);
        XCTAssertFalse(pd.hasCAD);
        XCTAssertFalse(pd.hasCVD);
        XCTAssertEqual(pd.ckd,CKD.Normal);
        XCTAssertEqual(pd.malignantNeoplasm, MalignantNeoplasm.No);
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
        XCTAssertEqual(pd.rutherford, RutherfordClassification.Class4);
    }
}
