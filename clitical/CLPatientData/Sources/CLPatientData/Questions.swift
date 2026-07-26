//
//  Questions.swift
//
//
//  Created by kmiyahara on 2023/01/04.
//
// References
// Miyata T. et al, Risk prediction model for early outcomes of
// revascularization for chronic limb-threatening ischaemia.
// Br J Surg. 2022 Oct 14;109(11):1123.
// https://doi.org/10.1093/bjs/znab036
// Miyata T. et al, Prediction Models for Two Year Overall Survival and
// Amputation Free Survival After Revascularisation for Chronic Limb
// Threatening Ischaemia.
// Eur J Vasc Endovasc Surg . 2022 Jun 7;S1078-5884(22)00340-9.
// https://doi.org/10.1016/j.ejvs.2022.05.038
// NOTICE
// occlusive lesion
// EJEVS occlusive classification
// | AI | FP | BK | 2yr occlusive lesion
// | +  | +- | +- | AI
// | -  | +  | +- | FP without AI
// | -  | -  | +  | Below IP
// | -  | -  | -  | undefined illegal

enum ThirtyDayDeathOrAmputationQuestions: CaseIterable {
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
    case hasNoOrLowGNRIRisk
    case isAmbulatory

    var coefficient: Double {
        switch self {
        case .intercept: return 2.86452
        case .hasAbnormalWBC: return -0.59896
        case .isUrgent: return -0.64861
        case .hasCHF: return -0.39326
        case .hasFever: return -0.3888
        case .hasCKD5D: return -0.33797
        case .hasNoAILesion: return -0.14474
        case .hasNoFPLesion: return 0.17229
        case .hasCVD: return -0.05239
        case .hasDL: return 0.05969
        case .hasRutherford5: return 0.12638
        case .hasModerateGNRIRisk: return 0.36795
        case .hasNoOrLowGNRIRisk: return 0.76479
        case .isAmbulatory: return 0.54391
        }
    }

    func applies(to patient: PatientData, gnriRisk: GNRIRisk) -> Bool {
        switch self {
        case .intercept: return true
        case .hasAbnormalWBC: return patient.hasAbnormalWBC
        case .isUrgent: return patient.isUrgent
        case .hasCHF: return patient.hasCHF
        case .hasFever: return patient.hasFever
        case .hasCKD5D: return patient.ckd == .g5D
        case .hasNoAILesion: return !patient.hasAILesion
        case .hasNoFPLesion: return !patient.hasFPLesion
        case .hasCVD: return patient.hasCVD
        case .hasDL: return patient.hasDyslipidemia
        case .hasRutherford5: return patient.rutherford == .class5
        case .hasModerateGNRIRisk: return gnriRisk == .moderate
        case .hasNoOrLowGNRIRisk: return gnriRisk == .noRisk || gnriRisk == .low
        case .isAmbulatory: return patient.activity == .ambulatory
        }
    }
}

enum ThirtyDayMALEQuestions: CaseIterable {
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

    var coefficient: Double {
        switch self {
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
        case .hasCHF: return -0.09218
        case .hasCAD: return 0.0375
        case .hasCKD5D: return -0.02024
        case .hasCVD: return 0.01592
        case .hasOthers: return 0.02649
        case .isSmoking: return 0.03109
        case .hasNoContraLateral: return 0.18822
        case .hasNoFPLesion: return 0.21082
        case .hasDL: return 0.2189
        case .hasNoOrLowGNRIRisk: return 0.32693
        case .hasModerateGNRIRisk: return 0.46838
        }
    }

    func applies(to patient: PatientData, age: Int, gnriRisk: GNRIRisk) -> Bool {
        switch self {
        case .intercept: return true
        case .isFemale: return patient.sex == .female
        case .age75To84: return (75...84).contains(age)
        case .ageOver85: return age >= 85
        case .hasAbnormalWBC: return patient.hasAbnormalWBC
        case .hasFever: return patient.hasFever
        case .hasLocalInfection: return patient.hasLocalInfection
        case .hasRutherford5: return patient.rutherford == .class5
        case .hasRutherford6: return patient.rutherford == .class6
        case .isAmbulatory: return patient.activity == .ambulatory
        case .isWheelChair: return patient.activity == .wheelchair
        case .isUrgent: return patient.isUrgent
        case .hasCHF: return patient.hasCHF
        case .hasCAD: return patient.hasCAD
        case .hasCKD5D: return patient.ckd == .g5D
        case .hasCVD: return patient.hasCVD
        case .hasOthers: return patient.hasOtherVD
        case .isSmoking: return patient.isSmoking
        case .hasNoContraLateral: return !patient.hasContraLateralLesion
        case .hasNoFPLesion: return !patient.hasFPLesion
        case .hasDL: return patient.hasDyslipidemia
        case .hasNoOrLowGNRIRisk: return gnriRisk == .noRisk || gnriRisk == .low
        case .hasModerateGNRIRisk: return gnriRisk == .moderate
        }
    }
}

enum TwoYearOSQuestions: CaseIterable {
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

    var coefficient: Double {
        switch self {
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

    func applies(to patient: PatientData, age: Int, gnriRisk: GNRIRisk) -> Bool {
        switch self {
        case .isFemale: return patient.sex == .female
        case .age65To74: return (65...74).contains(age)
        case .age75To84: return (75...84).contains(age)
        case .ageOver85: return age >= 85
        case .hasCHF: return patient.hasCHF
        case .hasCKDG3: return patient.ckd == .g3
        case .hasCKDG4: return patient.ckd == .g4
        case .hasCKDG5: return patient.ckd == .g5
        case .hasCKDG5D: return patient.ckd == .g5D
        case .hasModerateGNRIRisk: return gnriRisk == .moderate
        case .hasMajorGNRIRisk: return gnriRisk == .major
        case .isWheelchair: return patient.activity == .wheelchair
        case .isImmobile: return patient.activity == .immobile
        case .hasPastMalignancy: return patient.malignantNeoplasm == .pastHistory
        case .hasTreatingMalignancy: return patient.malignantNeoplasm == .underTreatment
        case .hasFPLesionWithoutAI: return !patient.hasAILesion && patient.hasFPLesion
        case .hasOnlyBKLesion:
            return !patient.hasAILesion && !patient.hasFPLesion && patient.hasBKLesion
        }
    }
}

enum TwoYearAFSQuestions: CaseIterable {
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
    case hasLocalInfection
    case hasFPLesionWithoutAI
    case hasOnlyBKLesion

    var coefficient: Double {
        switch self {
        case .isFemale: return -0.21
        case .age65To74: return 0.19
        case .age75To84: return 0.42
        case .ageOver85: return 0.62
        case .hasCHF: return 0.41
        case .hasCVD: return 0.10
        case .hasCKDG3: return 0.16
        case .hasCKDG4: return 0.36
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
        case .hasLocalInfection: return 0.15
        case .hasFPLesionWithoutAI: return -0.07
        case .hasOnlyBKLesion: return 0.15
        }
    }

    func applies(to patient: PatientData, age: Int, gnriRisk: GNRIRisk) -> Bool {
        switch self {
        case .isFemale: return patient.sex == .female
        case .age65To74: return (65...74).contains(age)
        case .age75To84: return (75...84).contains(age)
        case .ageOver85: return age >= 85
        case .hasCHF: return patient.hasCHF
        case .hasCVD: return patient.hasCVD
        case .hasCKDG3: return patient.ckd == .g3
        case .hasCKDG4: return patient.ckd == .g4
        case .hasCKDG5: return patient.ckd == .g5
        case .hasCKDG5D: return patient.ckd == .g5D
        case .hasModerateGNRIRisk: return gnriRisk == .moderate
        case .hasMajorGNRIRisk: return gnriRisk == .major
        case .isWheelchair: return patient.activity == .wheelchair
        case .isImmobile: return patient.activity == .immobile
        case .hasPastMalignancy: return patient.malignantNeoplasm == .pastHistory
        case .hasTreatingMalignancy: return patient.malignantNeoplasm == .underTreatment
        case .isUrgent: return patient.isUrgent
        case .hasFever: return patient.hasFever
        case .hasAbnormalWBC: return patient.hasAbnormalWBC
        case .hasLocalInfection: return patient.hasLocalInfection
        case .hasFPLesionWithoutAI: return !patient.hasAILesion && patient.hasFPLesion
        case .hasOnlyBKLesion:
            return !patient.hasAILesion && !patient.hasFPLesion && patient.hasBKLesion
        }
    }
}
