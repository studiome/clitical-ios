//
//  YesNo.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/11.
//

import Foundation

enum YesNo:  CaseIterable {
    case yes
    case no
    
    public func toBool() -> Bool{
        switch self{
        case .yes: return true
        case .no: return false
        }
    }
    
    public var label: String{
        switch self{
        case .yes: return "Yes"
        case .no: return "No"
        }
    }
}

extension Bool{
    public var label: String{
        switch self{
        case true: return "Yes"
        case false: return "No"
        }
    }
}
