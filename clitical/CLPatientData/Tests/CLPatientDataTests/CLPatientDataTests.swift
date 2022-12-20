import XCTest
@testable import CLPatientData

final class PatientDataTests: XCTestCase {
    func testInit() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let pd = PatientData();
        XCTAssertEqual(pd.sex, Sex.Female);
        XCTAssertNil(pd.age);
        XCTAssertNil(pd.height);
        XCTAssertNil(pd.weight);
        XCTAssertNil(pd.alb);
        XCTAssertEqual(pd.activity, Activity.Ambulatory);
        XCTAssertEqual(pd.ckd,CKD.Normal);
    }
}
