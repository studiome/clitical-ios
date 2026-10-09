//
//  Labels.swift
//  clitical-ios
//
//  Created by kmiyahara on 2026/07/13.
//
//  Localization keys for displaying each choice value.

import CLPatientData
import SwiftUI

extension Sex {
    var label: LocalizedStringKey {
        switch self {
        case .male: "SexMale"
        case .female: "SexFemale"
        }
    }
}

extension Activity {
    var label: LocalizedStringKey {
        switch self {
        case .ambulatory: "ActivityAmbulatory"
        case .wheelchair: "ActivityWheelchair"
        case .immobile: "ActivityImmobile"
        }
    }
}

extension CKD {
    var label: LocalizedStringKey {
        switch self {
        case .normal: "CKDNormal"
        case .g3: "CKDG3"
        case .g4: "CKDG4"
        case .g5: "CKDG5"
        case .g5D: "CKDG5D"
        }
    }
}

extension MalignantNeoplasm {
    var label: LocalizedStringKey {
        switch self {
        case .no: "MalignancyNo"
        case .pastHistory: "MalignancyPast"
        case .underTreatment: "MalignancyTreatment"
        }
    }
}

extension RutherfordClassification {
    var label: LocalizedStringKey {
        switch self {
        case .class4: "Rutherford4"
        case .class5: "Rutherford5"
        case .class6: "Rutherford6"
        }
    }
}

extension GNRIRisk {
    var label: LocalizedStringKey {
        switch self {
        case .noRisk: "GNRINoRisk"
        case .low: "GNRILowRisk"
        case .moderate: "GNRIModerateRisk"
        case .major: "GNRIMajorRisk"
        }
    }
}

extension TwoYearOSRisk {
    var label: LocalizedStringKey {
        switch self {
        case .low: "2YOSLowRisk"
        case .medium: "2YOSMediumRisk"
        case .high: "2YOSHighRisk"
        }
    }
}
