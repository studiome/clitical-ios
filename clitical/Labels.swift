//
//  Labels.swift
//  clitical-ios
//
//  Created by kmiyahara on 2026/07/13.
//
//  Localization keys for displaying each choice value.

import CLPatientData

extension Bool {
    var label: String {
        self ? "Yes" : "No"
    }
}

extension Sex {
    var label: String {
        switch self {
        case .male: return "SexMale"
        case .female: return "SexFemale"
        }
    }
}

extension Activity {
    var label: String {
        switch self {
        case .ambulatory: return "ActivityAmbulatory"
        case .wheelchair: return "ActivityWheelchair"
        case .immobile: return "ActivityImmobile"
        }
    }
}

extension CKD {
    var label: String {
        switch self {
        case .normal: return "CKDNormal"
        case .g3: return "CKDG3"
        case .g4: return "CKDG4"
        case .g5: return "CKDG5"
        case .g5D: return "CKDG5D"
        }
    }
}

extension MalignantNeoplasm {
    var label: String {
        switch self {
        case .no: return "MalignancyNo"
        case .pastHistory: return "MalignancyPast"
        case .underTreatment: return "MalignancyTreatment"
        }
    }
}

extension RutherfordClassification {
    var label: String {
        switch self {
        case .class4: return "Rutherford4"
        case .class5: return "Rutherford5"
        case .class6: return "Rutherford6"
        }
    }
}

extension GNRIRisk {
    var label: String {
        switch self {
        case .noRisk: return "GNRINoRisk"
        case .low: return "GNRILowRisk"
        case .moderate: return "GNRIModerateRisk"
        case .major: return "GNRIMajorRisk"
        }
    }
}

extension TwoYearOSRisk {
    var label: String {
        switch self {
        case .low: return "2YOSLowRisk"
        case .medium: return "2YOSMediumRisk"
        case .high: return "2YOSHighRisk"
        }
    }
}
