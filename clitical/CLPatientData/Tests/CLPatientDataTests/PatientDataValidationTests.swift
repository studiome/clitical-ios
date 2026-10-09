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

    @Test("Complete data validates")
    func completeDataValidates() {
        #expect(validPatientData().validate() == nil)
    }

    // MARK: - Missing values

    @Test("Missing values are reported in form order")
    func missingValuesAreReportedInFormOrder() {
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

    @Test("Age outside range is rejected", arguments: [17, 121, 0, -1])
    func ageOutsideRangeIsRejected(age: Int) {
        var pd = validPatientData()
        pd.age = age
        #expect(pd.validate() == .ageOutOfRange)
    }

    @Test("Age inside range is accepted", arguments: [18, 70, 120])
    func ageInsideRangeIsAccepted(age: Int) {
        var pd = validPatientData()
        pd.age = age
        #expect(pd.validate() == nil)
    }

    /// The unit mix-up this whole check exists for: 1.7 is a height in metres.
    @Test("Height outside range is rejected", arguments: [1.7, 0.0, 99.9, 250.1, -165.0])
    func heightOutsideRangeIsRejected(height: Double) {
        var pd = validPatientData()
        pd.height = height
        #expect(pd.validate() == .heightOutOfRange)
    }

    @Test("Height inside range is accepted", arguments: [100.0, 165.0, 250.0])
    func heightInsideRangeIsAccepted(height: Double) {
        var pd = validPatientData()
        pd.height = height
        #expect(pd.validate() == nil)
    }

    @Test("Weight outside range is rejected", arguments: [19.9, 0.0, 300.1, -60.0])
    func weightOutsideRangeIsRejected(weight: Double) {
        var pd = validPatientData()
        pd.weight = weight
        #expect(pd.validate() == .weightOutOfRange)
    }

    @Test("Weight inside range is accepted", arguments: [20.0, 60.0, 300.0])
    func weightInsideRangeIsAccepted(weight: Double) {
        var pd = validPatientData()
        pd.weight = weight
        #expect(pd.validate() == nil)
    }

    /// Albumin reported in g/L (35) instead of g/dL (3.5) is the mix-up here.
    @Test("Albumin outside range is rejected", arguments: [0.9, 6.1, 35.0, 0.0, -3.5])
    func albuminOutsideRangeIsRejected(alb: Double) {
        var pd = validPatientData()
        pd.alb = alb
        #expect(pd.validate() == .albuminOutOfRange)
    }

    @Test("Albumin inside range is accepted", arguments: [1.0, 3.5, 6.0])
    func albuminInsideRangeIsAccepted(alb: Double) {
        var pd = validPatientData()
        pd.alb = alb
        #expect(pd.validate() == nil)
    }

    // MARK: - Lesions

    @Test("Any artery lesion satisfies the lesion requirement")
    func anyArteryLesionSatisfiesRequirement() {
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

    @Test("Concomitant lesions do not satisfy the lesion requirement")
    func concomitantLesionsDoNotSatisfyRequirement() {
        var pd = validPatientData()
        pd.hasBKLesion = false
        pd.hasContraLateralLesion = true
        pd.hasOtherVD = true
        #expect(pd.validate() == .noLesionSelected)
    }
}
