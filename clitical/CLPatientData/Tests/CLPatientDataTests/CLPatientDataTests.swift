import XCTest
@testable import CLPatientData

final class PatientDataTests: XCTestCase {
    func testInit() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let pd = PatientData();
        XCTAssertEqual(pd.sex, Sex.Female);
        XCTAssertEqual(pd.activity, Activity.Ambulatory);
        XCTAssertEqual(pd.ckd,CKD.Normal);
    }
}
