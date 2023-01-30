//
//  QuestionError.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/24.
//

import Foundation
enum QuestionError{
    case NumberFormIsNil
    case IrrelevantLesion
    case DefaultError
    
    public var message: String{
        switch self{
        case .NumberFormIsNil: return "NumberFieldErrorMessage"
        case .IrrelevantLesion: return "IrrelevantLesionMessage"
        case .DefaultError: return "DefaultError"
        }
    }
}
