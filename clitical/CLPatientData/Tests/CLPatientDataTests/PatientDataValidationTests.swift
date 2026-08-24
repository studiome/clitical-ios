//
//  PatientDataValidationTests.swift
//
//  The app prints post-operative mortality figures, so a value that is
//  physiologically impossible — most often a unit mix-up such as entering
//  height in metres — must be refused rather than turned into a plausible
//  looking result.
//

import Testing
@testable import CLPatientData

@Suite
struct PatientDataValidationTests {

    /// A complete, plausible patient used as the starting point for the
    /// single-field failures below.
    private func validPatientData() -> PatientData {
        var pd = PatientData()
        pd.age = 70
        pd.sex = .male
        pd.height = 165.0
        pd.weight = 60.0
        pd.alb = 3.5
        pd.hasBKLesion = true
        return pd
    }

    @Test
    func testCompleteDataValidates() {
        #expect(validPatientData().validate() == nil)
    }

    // MARK: - Missing values

    @Test
    func testMissingValuesAreReportedInFormOrder() {
        var pd = PatientData()
        #expect(pd.validate() == .ageMissing)
        pd.age = 70
        #expect(pd.validate() == .sexMissing)
        pd.sex = .male
        #expect(pd.validate() == .heightMissing)
        pd.height = 165.0
        #expect(pd.validate() == .weightMissing)
        pd.weight = 60.0
        #expect(pd.validate() == .albuminMissing)
        pd.alb = 3.5
        #expect(pd.validate() == .noLesionSelected)
        pd.hasAILesion = true
        #expect(pd.validate() == nil)
    }

    // MARK: - Out-of-range values

    @Test(arguments: [17, 121, 0, -1])
    func testAgeOutsideRangeIsRejected(age: Int) {
        var pd = validPatientData()
        pd.age = age
        #expect(pd.validate() == .ageOutOfRange)
    }

    @Test(arguments: [18, 70, 120])
    func testAgeInsideRangeIsAccepted(age: Int) {
        var pd = validPatientData()
        pd.age = age
        #expect(pd.validate() == nil)
    }

    /// The unit mix-up this whole check exists for: 1.7 is a height in metres.
    @Test(arguments: [1.7, 0.0, 99.9, 250.1, -165.0])
    func testHeightOutsideRangeIsRejected(height: Double) {
        var pd = validPatientData()
        pd.height = height
        #expect(pd.validate() == .heightOutOfRange)
    }

    @Test(arguments: [100.0, 165.0, 250.0])
    func testHeightInsideRangeIsAccepted(height: Double) {
        var pd = validPatientData()
        pd.height = height
        #expect(pd.validate() == nil)
    }

    @Test(arguments: [19.9, 0.0, 300.1, -60.0])
    func testWeightOutsideRangeIsRejected(weight: Double) {
        var pd = validPatientData()
        pd.weight = weight
        #expect(pd.validate() == .weightOutOfRange)
    }

    @Test(arguments: [20.0, 60.0, 300.0])
    func testWeightInsideRangeIsAccepted(weight: Double) {
        var pd = validPatientData()
        pd.weight = weight
        #expect(pd.validate() == nil)
    }

    /// Albumin reported in g/L (35) instead of g/dL (3.5) is the mix-up here.
    @Test(arguments: [0.9, 6.1, 35.0, 0.0, -3.5])
    func testAlbuminOutsideRangeIsRejected(alb: Double) {
        var pd = validPatientData()
        pd.alb = alb
        #expect(pd.validate() == .albuminOutOfRange)
    }

    @Test(arguments: [1.0, 3.5, 6.0])
    func testAlbuminInsideRangeIsAccepted(alb: Double) {
        var pd = validPatientData()
        pd.alb = alb
        #expect(pd.validate() == nil)
    }

    // MARK: - Lesions

    @Test
    func testAnyArteryLesionSatisfiesTheLesionRequirement() {
        for lesion in [\PatientData.hasAILesion,
                       \PatientData.hasFPLesion,
                       \PatientData.hasBKLesion] {
            var pd = validPatientData()
            pd.hasAILesion = false
            pd.hasFPLesion = false
            pd.hasBKLesion = false
            pd[keyPath: lesion] = true
            #expect(pd.validate() == nil)
        }
    }

    @Test
    func testConcomitantLesionsDoNotSatisfyTheLesionRequirement() {
        var pd = validPatientData()
        pd.hasBKLesion = false
        pd.hasContraLateralLesion = true
        pd.hasOtherVD = true
        #expect(pd.validate() == .noLesionSelected)
    }
}
