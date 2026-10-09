//
//  QuestionError.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//
//  Turns a `PatientDataValidationError` into the message shown in the
//  validation alert. Range messages quote the accepted range so that a unit
//  mix-up (a height typed in metres, albumin in g/L) is self-explanatory.
//

import Foundation
import CLPatientData

// These literal localizable API calls ensure Xcode includes the keys that are
// resolved dynamically above when exporting localization catalogs.
private enum ValidationMessageLocalizationKeys {
    static let ageRequired = String(localized: "AgeRequiredErrorMessage")
    static let ageRange = String(localized: "AgeRangeErrorMessage")
    static let sexRequired = String(localized: "SexRequiredErrorMessage")
    static let heightRequired = String(localized: "HeightRequiredErrorMessage")
    static let heightRange = String(localized: "HeightRangeErrorMessage")
    static let weightRequired = String(localized: "WeightRequiredErrorMessage")
    static let weightRange = String(localized: "WeightRangeErrorMessage")
    static let albuminRequired = String(localized: "AlbuminRequiredErrorMessage")
    static let albuminRange = String(localized: "AlbuminRangeErrorMessage")
    static let noLesion = String(localized: "IrrelevantLesionMessage")
    static let defaultError = String(localized: "DefaultError")
}

extension PatientDataValidationError {
    /// The localization key of the alert message.
    var messageKey: String {
        switch self {
        case .ageMissing: "AgeRequiredErrorMessage"
        case .ageOutOfRange: "AgeRangeErrorMessage"
        case .sexMissing: "SexRequiredErrorMessage"
        case .heightMissing: "HeightRequiredErrorMessage"
        case .heightOutOfRange: "HeightRangeErrorMessage"
        case .weightMissing: "WeightRequiredErrorMessage"
        case .weightOutOfRange: "WeightRangeErrorMessage"
        case .albuminMissing: "AlbuminRequiredErrorMessage"
        case .albuminOutOfRange: "AlbuminRangeErrorMessage"
        case .noLesionSelected: "IrrelevantLesionMessage"
        }
    }

    /// The bounds substituted into the range messages, so the accepted range
    /// is stated once — here — rather than duplicated in every translation.
    private var rangeArguments: [CVarArg]? {
        switch self {
        case .ageOutOfRange:
            [PatientData.validAgeRange.lowerBound.formatted(),
             PatientData.validAgeRange.upperBound.formatted()]
        case .heightOutOfRange:
            Self.bounds(of: PatientData.validHeightRange)
        case .weightOutOfRange:
            Self.bounds(of: PatientData.validWeightRange)
        case .albuminOutOfRange:
            Self.bounds(of: PatientData.validAlbuminRange)
        default:
            nil
        }
    }

    private static func bounds(of range: ClosedRange<Double>) -> [CVarArg] {
        [range.lowerBound.formatted(.number), range.upperBound.formatted(.number)]
    }

    /// Resolves the message against the app's current language.
    func message(using localization: LocalizationManager) -> String {
        let format = localization.string(forKey: messageKey)
        guard let rangeArguments else { return format }
        return String(format: format, arguments: rangeArguments)
    }
}
