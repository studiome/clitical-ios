//
//  PatientRisk.swift
//
//
//  Created by kmiyahara on 2023/01/02.
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

import Foundation

public struct PatientRisk {
    private let twoYearOSH0Coeff = 0.922
    private let twoYearAFSH0Coeff = 0.876

    public var gnri: Double? {
        calcGNRI()
    }

    public var gnriRisk: GNRIRisk? {
        classifyGNRI()
    }

    // 0.0 ... 1.0
    public var predicted30DDeathOrAmputation: Double? {
        calcPredicted30DDA()
    }

    // 0.0 ... 1.0
    public var predicted30DMALE: Double? {
        calcPredicted30DMALE()
    }

    // 0.0 ... 1.0
    public var predicted2YOS: Double? {
        calcPredicted2YOS()
    }

    public var predicted2YOSRisk: TwoYearOSRisk? {
        classifyOS()
    }

    // 0.0 ... 1.0
    public var predicted2YAFS: Double? {
        calcPredicted2YAFS()
    }

    var patientData: PatientData

    public init(of patientData: PatientData) {
        self.patientData = patientData
    }

    private func calcGNRI() -> Double? {
        guard let heightCM = patientData.height,
              let weight = patientData.weight,
              let alb = patientData.alb,
              heightCM > 0.0, weight > 0.0, alb > 0.0 else {
            return nil
        }
        let heightM = heightCM / 100.0
        let weightIndex = min(weight / (22.0 * pow(heightM, 2)), 1.0)
        return 14.89 * alb + 41.7 * weightIndex
    }

    private func calcPredicted30DDA() -> Double? {
        guard let gnriRisk else {
            return nil
        }
        let sigma = ThirtyDayDeathOrAmputationQuestions.allCases
            .filter { $0.applies(to: patientData, gnriRisk: gnriRisk) }
            .map(\.coefficient)
            .reduce(0.0, +)
        return 1.0 / (1.0 + exp(sigma))
    }

    private func calcPredicted30DMALE() -> Double? {
        // `applies(to:)` reads sex as "female or not", which would quietly
        // treat an unanswered sex as male, so require it explicitly.
        guard let age = patientData.age, patientData.sex != nil, let gnriRisk else {
            return nil
        }
        let sigma = ThirtyDayMALEQuestions.allCases
            .filter { $0.applies(to: patientData, age: age, gnriRisk: gnriRisk) }
            .map(\.coefficient)
            .reduce(0.0, +)
        return 1.0 / (1.0 + exp(sigma))
    }

    private func calcPredicted2YOS() -> Double? {
        guard let age = patientData.age, patientData.sex != nil, let gnriRisk else {
            return nil
        }
        let sigma = TwoYearOSQuestions.allCases
            .filter { $0.applies(to: patientData, age: age, gnriRisk: gnriRisk) }
            .map(\.coefficient)
            .reduce(0.0, +)
        return pow(twoYearOSH0Coeff, exp(sigma))
    }

    private func calcPredicted2YAFS() -> Double? {
        guard let age = patientData.age, patientData.sex != nil, let gnriRisk else {
            return nil
        }
        let sigma = TwoYearAFSQuestions.allCases
            .filter { $0.applies(to: patientData, age: age, gnriRisk: gnriRisk) }
            .map(\.coefficient)
            .reduce(0.0, +)
        return pow(twoYearAFSH0Coeff, exp(sigma))
    }

    private func classifyGNRI() -> GNRIRisk? {
        guard let gnri else {
            return nil
        }
        // Per the reference papers (Miyata et al.):
        // no risk >=98, low 92..<98, moderate 82..<92, major <82
        switch gnri {
        case 98.0...Double.infinity:
            return .noRisk
        case 92.0..<98.0:
            return .low
        case 82.0..<92.0:
            return .moderate
        case 0.0..<82.0:
            return .major
        default:
            return nil
        }
    }

    private func classifyOS() -> TwoYearOSRisk? {
        guard let os = predicted2YOS else {
            return nil
        }
        switch os {
        case 0.70...1.0:
            return .low
        case 0.50..<0.70:
            return .medium
        case 0.0..<0.50:
            return .high
        default:
            return nil
        }
    }
}

public enum GNRIRisk {
    case noRisk
    case low
    case moderate
    case major
}

public enum TwoYearOSRisk {
    case low
    case medium
    case high
}
