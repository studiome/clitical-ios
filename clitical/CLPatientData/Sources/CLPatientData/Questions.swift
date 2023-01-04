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

enum ThirtyDaysDeathOrAmputationQuestions: CaseIterable{
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
}

enum ThirtyDaysMALEQuestions: CaseIterable{
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
}

enum TwoYearOSQuestions: CaseIterable{
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
    case hasMajorGNRIRisk
    case isWheelchair
    case isImmobile
    case hasPastMalignancy
    case hasTreatingMalignancy
    case hasFPLesion
    case hasBKLesion
}

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
    case hasFPLesion
    case hasBKLesion
}
