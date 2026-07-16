//
//  QuestionError.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

enum QuestionError {
    case numberFormIsNil
    case irrelevantLesion
    case defaultError

    var message: String {
        switch self {
        case .numberFormIsNil: return "NumberFieldErrorMessage"
        case .irrelevantLesion: return "IrrelevantLesionMessage"
        case .defaultError: return "DefaultError"
        }
    }
}
