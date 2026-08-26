//
//  PatientDataValidation.swift
//
//  Entry checks that run before any prediction. The models happily accept a
//  height of 1.7 — a metre value typed into a centimetre field — and return a
//  plausible looking risk, so out-of-range entries have to be refused here
//  rather than turned into a number a clinician might read.
//

/// The first problem found in a `PatientData`, in the order the questions
/// appear on the form.
public enum PatientDataValidationError: Equatable {
    case ageMissing
    case ageOutOfRange
    case sexMissing
    case heightMissing
    case heightOutOfRange
    case weightMissing
    case weightOutOfRange
    case albuminMissing
    case albuminOutOfRange
    case noLesionSelected
}

public extension PatientData {
    /// Plausible ranges for an adult undergoing revascularisation. They are
    /// deliberately wider than the derivation cohort: the point is to catch
    /// unit mix-ups and typos, not to restrict the model's own population.
    static let validAgeRange = 18...120
    /// Centimetres. Excludes metre values (1.7) and millimetre values (1700).
    static let validHeightRange = 100.0...250.0
    /// Kilograms.
    static let validWeightRange = 20.0...300.0
    /// g/dL. Excludes g/L values (35.0).
    static let validAlbuminRange = 1.0...6.0

    /// Returns the first problem that prevents a prediction, or `nil` when the
    /// data is complete and plausible.
    func validate() -> PatientDataValidationError? {
        guard let age else { return .ageMissing }
        guard Self.validAgeRange.contains(age) else { return .ageOutOfRange }

        guard sex != nil else { return .sexMissing }

        guard let height else { return .heightMissing }
        guard Self.validHeightRange.contains(height) else { return .heightOutOfRange }

        guard let weight else { return .weightMissing }
        guard Self.validWeightRange.contains(weight) else { return .weightOutOfRange }

        guard let alb else { return .albuminMissing }
        guard Self.validAlbuminRange.contains(alb) else { return .albuminOutOfRange }

        // The 2-year models classify the occlusive lesion by the most proximal
        // site involved, so at least one artery site has to be marked. The
        // concomitant-lesion questions are separate covariates and do not
        // count towards this.
        guard hasAILesion || hasFPLesion || hasBKLesion else { return .noLesionSelected }

        return nil
    }
}
