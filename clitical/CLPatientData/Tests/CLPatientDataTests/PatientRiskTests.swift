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
    
    func testErrorCase() throws{
        let pd = PatientData();
        pd.height=0.0;
        let risk = PatientRisk(ofPatient: pd);
        XCTAssertNil(risk.gnri);
    }
    
    func testNormalCase() throws{
        let pd = PatientData();
        pd.weight = 50.0;
        pd.height = 1.50;
        pd.alb = 4.0;
        
        let risk = PatientRisk(ofPatient: pd);
        XCTAssertEqual(String(format: "%.1f", risk.gnri!), "101.3")
    }
    
    func testLowRiskCase() throws{
        let pd = PatientData();
        pd.weight = 60.0;
        pd.height = 1.65;
        pd.alb = 4.0;
        
        let risk = PatientRisk(ofPatient: pd);
        XCTAssertEqual(String(format: "%.1f", risk.gnri!), "101.3")
    }
    
    func testMediumRiskCase() throws{
        let pd = PatientData();
        pd.weight = 55.0;
        pd.height = 1.53;
        pd.alb = 3.5;
        
        let risk = PatientRisk(ofPatient: pd);
        XCTAssertEqual(String(format: "%.1f", risk.gnri!), "93.8")
    }
    
    func testHighRiskCase1() throws{
        let pd = PatientData();
        pd.weight = 55.1;
        pd.height = 1.75;
        pd.alb = 3.5;
        
        let risk = PatientRisk(ofPatient: pd);
        XCTAssertEqual(String(format: "%.1f", risk.gnri!), "86.2")
    }
    
    func testHighRiskCase2() throws{
        let pd = PatientData();
        pd.weight = 30.0;
        pd.height = 1.55;
        pd.alb = 3.2;
        
        let risk = PatientRisk(ofPatient: pd);
        XCTAssertEqual(String(format: "%.1f", risk.gnri!), "71.3")
    }
}
