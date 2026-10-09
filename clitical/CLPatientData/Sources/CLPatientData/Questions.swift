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

/// Everything an `applies(to:)` check may need, resolved once up front.
struct RiskContext {
    let patient: PatientData
    let age: Int
    let gnriRisk: GNRIRisk
}

/// One term of a regression model: a coefficient that contributes to the
/// linear predictor when its condition holds for the patient.
protocol RiskFactor: CaseIterable {
    var coefficient: Double { get }
    func applies(to context: RiskContext) -> Bool
}

extension RiskFactor {
    /// Sum of the coefficients of every factor that applies.
    static func linearPredictor(for context: RiskContext) -> Double {
        allCases.lazy
            .filter { $0.applies(to: context) }
            .map(\.coefficient)
            .reduce(0, +)
    }
}

enum ThirtyDayDeathOrAmputationQuestions: RiskFactor {
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
        case .intercept: 2.86452
        case .hasAbnormalWBC: -0.59896
        case .isUrgent: -0.64861
        case .hasCHF: -0.39326
        case .hasFever: -0.3888
        case .hasCKD5D: -0.33797
        case .hasNoAILesion: -0.14474
        case .hasNoFPLesion: 0.17229
        case .hasCVD: -0.05239
        case .hasDL: 0.05969
        case .hasRutherford5: 0.12638
        case .hasModerateGNRIRisk: 0.36795
        case .hasNoOrLowGNRIRisk: 0.76479
        case .isAmbulatory: 0.54391
        }
    }

    func applies(to context: RiskContext) -> Bool {
        let patient = context.patient
        let gnriRisk = context.gnriRisk
        return switch self {
        case .intercept: true
        case .hasAbnormalWBC: patient.hasAbnormalWBC
        case .isUrgent: patient.isUrgent
        case .hasCHF: patient.hasCHF
        case .hasFever: patient.hasFever
        case .hasCKD5D: patient.ckd == .g5D
        case .hasNoAILesion: !patient.hasAILesion
        case .hasNoFPLesion: !patient.hasFPLesion
        case .hasCVD: patient.hasCVD
        case .hasDL: patient.hasDyslipidemia
        case .hasRutherford5: patient.rutherford == .class5
        case .hasModerateGNRIRisk: gnriRisk == .moderate
        case .hasNoOrLowGNRIRisk: gnriRisk == .noRisk || gnriRisk == .low
        case .isAmbulatory: patient.activity == .ambulatory
        }
    }
}

enum ThirtyDayMALEQuestions: RiskFactor {
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
        case .intercept: 2.2575
        case .isFemale: 0.24023
        case .age75To84: 0.16816
        case .ageOver85: 0.46026
        case .hasAbnormalWBC: -0.50671
        case .hasFever: -0.33461
        case .hasLocalInfection: -0.28088
        case .hasRutherford5: 0.14299
        case .hasRutherford6: -0.26513
        case .isAmbulatory: 0.17103
        case .isWheelChair: -0.22555
        case .isUrgent: -0.20964
        case .hasCHF: -0.09218
        case .hasCAD: 0.0375
        case .hasCKD5D: -0.02024
        case .hasCVD: 0.01592
        case .hasOthers: 0.02649
        case .isSmoking: 0.03109
        case .hasNoContraLateral: 0.18822
        case .hasNoFPLesion: 0.21082
        case .hasDL: 0.2189
        case .hasNoOrLowGNRIRisk: 0.32693
        case .hasModerateGNRIRisk: 0.46838
        }
    }

    func applies(to context: RiskContext) -> Bool {
        let patient = context.patient
        let age = context.age
        let gnriRisk = context.gnriRisk
        return switch self {
        case .intercept: true
        case .isFemale: patient.sex == .female
        case .age75To84: (75...84).contains(age)
        case .ageOver85: age >= 85
        case .hasAbnormalWBC: patient.hasAbnormalWBC
        case .hasFever: patient.hasFever
        case .hasLocalInfection: patient.hasLocalInfection
        case .hasRutherford5: patient.rutherford == .class5
        case .hasRutherford6: patient.rutherford == .class6
        case .isAmbulatory: patient.activity == .ambulatory
        case .isWheelChair: patient.activity == .wheelchair
        case .isUrgent: patient.isUrgent
        case .hasCHF: patient.hasCHF
        case .hasCAD: patient.hasCAD
        case .hasCKD5D: patient.ckd == .g5D
        case .hasCVD: patient.hasCVD
        case .hasOthers: patient.hasOtherVD
        case .isSmoking: patient.isSmoking
        case .hasNoContraLateral: !patient.hasContraLateralLesion
        case .hasNoFPLesion: !patient.hasFPLesion
        case .hasDL: patient.hasDyslipidemia
        case .hasNoOrLowGNRIRisk: gnriRisk == .noRisk || gnriRisk == .low
        case .hasModerateGNRIRisk: gnriRisk == .moderate
        }
    }
}

enum TwoYearOSQuestions: RiskFactor {
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
        case .isFemale: -0.25
        case .age65To74: 0.31
        case .age75To84: 0.76
        case .ageOver85: 1.04
        case .hasCHF: 0.50
        case .hasCKDG3: 0.27
        case .hasCKDG4: 0.61
        case .hasCKDG5: 0.76
        case .hasCKDG5D: 1.01
        case .hasModerateGNRIRisk: 0.14
        case .hasMajorGNRIRisk: 0.52
        case .isWheelchair: 0.28
        case .isImmobile: 0.77
        case .hasPastMalignancy: 0.20
        case .hasTreatingMalignancy: 0.56
        case .hasFPLesionWithoutAI: -0.07
        case .hasOnlyBKLesion: 0.16
        }
    }

    func applies(to context: RiskContext) -> Bool {
        let patient = context.patient
        let age = context.age
        let gnriRisk = context.gnriRisk
        return switch self {
        case .isFemale: patient.sex == .female
        case .age65To74: (65...74).contains(age)
        case .age75To84: (75...84).contains(age)
        case .ageOver85: age >= 85
        case .hasCHF: patient.hasCHF
        case .hasCKDG3: patient.ckd == .g3
        case .hasCKDG4: patient.ckd == .g4
        case .hasCKDG5: patient.ckd == .g5
        case .hasCKDG5D: patient.ckd == .g5D
        case .hasModerateGNRIRisk: gnriRisk == .moderate
        case .hasMajorGNRIRisk: gnriRisk == .major
        case .isWheelchair: patient.activity == .wheelchair
        case .isImmobile: patient.activity == .immobile
        case .hasPastMalignancy: patient.malignantNeoplasm == .pastHistory
        case .hasTreatingMalignancy: patient.malignantNeoplasm == .underTreatment
        case .hasFPLesionWithoutAI: !patient.hasAILesion && patient.hasFPLesion
        case .hasOnlyBKLesion:
            !patient.hasAILesion && !patient.hasFPLesion && patient.hasBKLesion
        }
    }
}

enum TwoYearAFSQuestions: RiskFactor {
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
        case .isFemale: -0.21
        case .age65To74: 0.19
        case .age75To84: 0.42
        case .ageOver85: 0.62
        case .hasCHF: 0.41
        case .hasCVD: 0.10
        case .hasCKDG3: 0.16
        case .hasCKDG4: 0.36
        case .hasCKDG5: 0.73
        case .hasCKDG5D: 0.81
        case .hasModerateGNRIRisk: 0.09
        case .hasMajorGNRIRisk: 0.45
        case .isWheelchair: 0.37
        case .isImmobile: 0.78
        case .hasPastMalignancy: 0.15
        case .hasTreatingMalignancy: 0.39
        case .isUrgent: 0.34
        case .hasFever: 0.36
        case .hasAbnormalWBC: 0.19
        case .hasLocalInfection: 0.15
        case .hasFPLesionWithoutAI: -0.07
        case .hasOnlyBKLesion: 0.15
        }
    }

    func applies(to context: RiskContext) -> Bool {
        let patient = context.patient
        let age = context.age
        let gnriRisk = context.gnriRisk
        return switch self {
        case .isFemale: patient.sex == .female
        case .age65To74: (65...74).contains(age)
        case .age75To84: (75...84).contains(age)
        case .ageOver85: age >= 85
        case .hasCHF: patient.hasCHF
        case .hasCVD: patient.hasCVD
        case .hasCKDG3: patient.ckd == .g3
        case .hasCKDG4: patient.ckd == .g4
        case .hasCKDG5: patient.ckd == .g5
        case .hasCKDG5D: patient.ckd == .g5D
        case .hasModerateGNRIRisk: gnriRisk == .moderate
        case .hasMajorGNRIRisk: gnriRisk == .major
        case .isWheelchair: patient.activity == .wheelchair
        case .isImmobile: patient.activity == .immobile
        case .hasPastMalignancy: patient.malignantNeoplasm == .pastHistory
        case .hasTreatingMalignancy: patient.malignantNeoplasm == .underTreatment
        case .isUrgent: patient.isUrgent
        case .hasFever: patient.hasFever
        case .hasAbnormalWBC: patient.hasAbnormalWBC
        case .hasLocalInfection: patient.hasLocalInfection
        case .hasFPLesionWithoutAI: !patient.hasAILesion && patient.hasFPLesion
        case .hasOnlyBKLesion:
            !patient.hasAILesion && !patient.hasFPLesion && patient.hasBKLesion
        }
    }
}
