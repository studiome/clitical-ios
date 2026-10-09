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

public struct PatientRisk: Equatable, Sendable {
    public let gnri: Double
    public let gnriRisk: GNRIRisk
    // 0.0 ... 1.0
    public let predicted30DDeathOrAmputation: Double
    // 0.0 ... 1.0
    public let predicted30DMALE: Double
    // 0.0 ... 1.0
    public let predicted2YOS: Double
    public let predicted2YOSRisk: TwoYearOSRisk
    // 0.0 ... 1.0
    public let predicted2YAFS: Double

    private static let twoYearOSH0Coeff = 0.922
    private static let twoYearAFSH0Coeff = 0.876

    /// Returns `nil` when a required input (height, weight, albumin, age or
    /// sex) is missing or implausible. Sex is a covariate of most of the
    /// models and an unanswered sex would quietly be treated as male, so the
    /// prediction is refused as a whole rather than partially resolved.
    public init?(patientData: PatientData) {
        guard let age = patientData.age,
              patientData.sex != nil,
              let gnri = Self.calcGNRI(patientData),
              let gnriRisk = Self.classifyGNRI(gnri) else {
            return nil
        }
        let context = RiskContext(patient: patientData, age: age, gnriRisk: gnriRisk)

        let predicted2YOS = pow(Self.twoYearOSH0Coeff, exp(TwoYearOSQuestions.linearPredictor(for: context)))
        guard let predicted2YOSRisk = Self.classifyOS(predicted2YOS) else {
            return nil
        }

        self.gnri = gnri
        self.gnriRisk = gnriRisk
        self.predicted30DDeathOrAmputation = Self.logistic(
            ThirtyDayDeathOrAmputationQuestions.linearPredictor(for: context))
        self.predicted30DMALE = Self.logistic(
            ThirtyDayMALEQuestions.linearPredictor(for: context))
        self.predicted2YOS = predicted2YOS
        self.predicted2YOSRisk = predicted2YOSRisk
        self.predicted2YAFS = pow(Self.twoYearAFSH0Coeff, exp(TwoYearAFSQuestions.linearPredictor(for: context)))
    }

    private static func logistic(_ sigma: Double) -> Double {
        1.0 / (1.0 + exp(sigma))
    }

    private static func calcGNRI(_ patientData: PatientData) -> Double? {
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

    private static func classifyGNRI(_ gnri: Double) -> GNRIRisk? {
        // Per the reference papers (Miyata et al.):
        // no risk >=98, low 92..<98, moderate 82..<92, major <82
        switch gnri {
        case 98.0...:
            .noRisk
        case 92.0..<98.0:
            .low
        case 82.0..<92.0:
            .moderate
        case 0.0..<82.0:
            .major
        default:
            nil
        }
    }

    private static func classifyOS(_ os: Double) -> TwoYearOSRisk? {
        switch os {
        case 0.70...1.0:
            .low
        case 0.50..<0.70:
            .medium
        case 0.0..<0.50:
            .high
        default:
            nil
        }
    }
}

public enum GNRIRisk: Sendable, Hashable {
    case noRisk
    case low
    case moderate
    case major
}

public enum TwoYearOSRisk: Sendable, Hashable {
    case low
    case medium
    case high
}
