//
//  Questions.swift
//  
//
//  Created by kmiyahara on 2023/01/04.
//

public enum AllQuestions:  CaseIterable{
    case sex
    case age
    case height
    case weigth
    case albumin
    case activity
    case chf
    case cad
    case cvd
    case ckd
    case malignancy
    case lesionAI
    case lesionFP
    case lesionBK
    case urgency
    case fever
    case wbc
    case infection
    case dl
    case smoking
    case contralateral
    case others
    case rutherford
}

enum ThirtyDayDeathOrAmputationQuestions:  CaseIterable{
    case intercept
    case hasAbnormalWBC
    case isUrgent
    case hasCHF
    case hasFever
    case hasCKD5D
    case hasNoAILesion
    case hasNoFPLesion
    case hasCVD
    case hasDL
    case hasRutherford5
    case hasModerateGNRIRisk
    case hasGNRINoOrLowRisk
    case isAmbulatory
    
    var coefficient:Double {
        switch self{
        case .intercept: return 2.86452
        case .hasAbnormalWBC: return  -0.59896
        case .isUrgent: return  -0.64861
        case .hasCHF: return -0.39326
        case .hasFever: return -0.3888
        case .hasCKD5D: return  -0.33797
        case .hasNoAILesion: return -0.14474
        case .hasNoFPLesion: return 0.17229
        case .hasCVD: return -5239
        case .hasDL: return  5969
        case .hasRutherford5: return  0.12638
        case .hasModerateGNRIRisk: return  0.36795
        case .hasGNRINoOrLowRisk: return  0.76479
        case .isAmbulatory: return  0.54391
        }
    }
}

let ThirtyDayDeathOrAmputationCoeffs: [Double]
= ThirtyDayDeathOrAmputationQuestions.allCases.map{$0.coefficient}

enum ThirtyDayMALEQuestions: CaseIterable{
    case intercept
    case isFemale
    case age75To84
    case ageOver85
    case hasAbnormalWBC
    case hasFever
    case hasLocalInfection
    case hasRutherford5
    case hasRutherford6
    case isAmbulatory
    case isWheelChair
    case isUrgent
    case hasCHF
    case hasCAD
    case hasCKD5D
    case hasCVD
    case hasOthers
    case isSmoking
    case hasNoContraLateral
    case hasNoFPLesion
    case hasDL
    case hasNoOrLowGNRIRisk
    case hasModerateGNRIRisk
    
    var coefficient:Double {
        switch self{
        case .intercept: return 2.2575
        case .isFemale: return 0.24023
        case .age75To84: return 0.16816
        case .ageOver85: return 0.46026
        case .hasAbnormalWBC: return -0.50671
        case .hasFever: return -0.33461
        case .hasLocalInfection: return -0.28088
        case .hasRutherford5: return 0.14299
        case .hasRutherford6: return -0.26513
        case .isAmbulatory: return 0.17103
        case .isWheelChair: return -0.22555
        case .isUrgent: return -0.20964
        case .hasCHF: return -9218
        case .hasCAD: return 375
        case .hasCKD5D: return -2024
        case .hasCVD: return 1592
        case .hasOthers: return 2649
        case .isSmoking: return 3109
        case .hasNoContraLateral: return 0.18822
        case .hasNoFPLesion: return 0.21082
        case .hasDL: return 0.2189
        case .hasNoOrLowGNRIRisk: return 0.32693
        case .hasModerateGNRIRisk: return 0.46838
        }
    }
}

let ThirtyDayMALECoeffs: [Double]
= ThirtyDayMALEQuestions.allCases.map{$0.coefficient}

enum TwoYearOSQuestions: Int, CaseIterable{
    case isFemale
    case age65To74
    case age75To84
    case ageOver85
    case hasCHF
    case hasCKDG3
    case hasCKDG4
    case hasCKDG5
    case hasCKDG5D
    case hasModerateGNRIRisk
    case hasMajorGNRIRisk
    case isWheelchair
    case isImmobile
    case hasPastMalignancy
    case hasTreatingMalignancy
    case hasFPLesionWithoutAI
    case hasOnlyBKLesion
    
    var coefficient: Double{
        switch self{
        case .isFemale: return -0.25
        case .age65To74: return 0.31
        case .age75To84: return 0.76
        case .ageOver85: return 1.04
        case .hasCHF: return 0.50
        case .hasCKDG3: return 0.27
        case .hasCKDG4: return 0.61
        case .hasCKDG5: return 0.76
        case .hasCKDG5D: return 1.01
        case .hasModerateGNRIRisk: return 0.14
        case .hasMajorGNRIRisk: return 0.52
        case .isWheelchair: return 0.28
        case .isImmobile: return 0.77
        case .hasPastMalignancy: return 0.20
        case .hasTreatingMalignancy: return 0.56
        case .hasFPLesionWithoutAI: return -0.07
        case .hasOnlyBKLesion: return 0.16
        }
    }
}

let TwoYearOSCoeffs: [Double]
= TwoYearOSQuestions.allCases.map{$0.coefficient}

enum TwoYearAFSQuestions: CaseIterable{
    case isFemale
    case age65To74
    case age75To84
    case ageOver85
    case hasCHF
    case hasCVD
    case hasCKDG3
    case hasCKDG4
    case hasCKDG5
    case hasCKDG5D
    case hasModerateGNRIRisk
    case hasMajorGNRIRisk
    case isWheelchair
    case isImmobile
    case hasPastMalignancy
    case hasTreatingMalignancy
    case isUrgent
    case hasFever
    case hasAbnormalWBC
    case hasLocalInfetion
    case hasFPLesionWithoutAI
    case hasOnlyBKLesion
    
    var coefficient:Double {
        switch self{
        case .isFemale: return -0.21
        case .age65To74: return 0.19
        case .age75To84: return 0.42
        case .ageOver85: return 0.62
        case .hasCHF: return 0.41
        case .hasCVD: return 0.10
        case .hasCKDG3: return 0.16
        case .hasCKDG4: return 0.35
        case .hasCKDG5: return 0.73
        case .hasCKDG5D: return 0.81
        case .hasModerateGNRIRisk: return 0.09
        case .hasMajorGNRIRisk: return 0.45
        case .isWheelchair: return 0.37
        case .isImmobile: return 0.78
        case .hasPastMalignancy: return 0.15
        case .hasTreatingMalignancy: return 0.39
        case .isUrgent: return 0.34
        case .hasFever: return 0.36
        case .hasAbnormalWBC: return 0.19
        case .hasLocalInfetion: return 0.15
        case .hasFPLesionWithoutAI: return -0.07
        case .hasOnlyBKLesion: return 0.15
        }
    }
}

let TwoYearAFSCoeffs: [Double]
= TwoYearAFSQuestions.allCases.map{$0.coefficient}
