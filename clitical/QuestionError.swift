//
//  QuestionError.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

enum QuestionError {
    case ageIsNil
    case heightIsNil
    case weightIsNil
    case albuminIsNil
    case irrelevantLesion
    case defaultError

    var message: String {
        switch self {
        case .ageIsNil: return "AgeRequiredErrorMessage"
        case .heightIsNil: return "HeightRequiredErrorMessage"
        case .weightIsNil: return "WeightRequiredErrorMessage"
        case .albuminIsNil: return "AlbuminRequiredErrorMessage"
        case .irrelevantLesion: return "IrrelevantLesionMessage"
        case .defaultError: return "DefaultError"
        }
    }
}
