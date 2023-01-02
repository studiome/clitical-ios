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
        let pd = PatientData();
        var risk = PatientRisk(ofPatient: pd);
        XCTAssertNil(risk.gnri);
        XCTAssertNil(risk.gnriRisk);
        XCTAssertNil(risk.predicted30DDeathOrAmputation);
        XCTAssertNil(risk.predicted30DMALE);
        XCTAssertNil(risk.predicted2YOS);
        XCTAssertNil(risk.predicted2YOSRisk);
        XCTAssertNil(risk.predicted2YAFS);
    }
}
