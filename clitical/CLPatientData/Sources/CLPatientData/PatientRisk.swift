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

import Foundation

public struct PatientRisk {
    private let twoYearOSH0Coeff = 0.922
    private let twoYearAFSH0Coeff = 0.876
    
    var gnri: Double? {
        return calcGNRI()
    }
    
    lazy var gnriRisk: GNRIRisk? = classifyGNRI()
    
    lazy var predicted30DDeathOrAmputation: Double? = calcPredicted30DDA()
    // 0.0 ... 1.0
    
    lazy var predicted30DMALE: Double? = calcPredicted30DMALE()// 0.0 ... 1.0
    
    lazy var predicted2YOS: Double? = calcPredicted2YOS()// 0.0 ... 1.0
    
    lazy var predicted2YOSRisk: TwoYearOSRisk? = classifyOS()
    
    lazy var predicted2YAFS: Double? = calcPredicted2YAFS() // 0.0 ... 1.0
    
    var patientData: PatientData
    
    init(ofPatient patientData: PatientData){
        self.patientData = patientData;
    }
    
    private func calcGNRI() -> Double? {
        guard let height = patientData.height else {
            return nil
        }
        guard let weight = patientData.weight else {
            return nil
        }
        guard let alb = patientData.alb else {
            return nil
        }
        guard height != 0.0 else {
            return nil
        }
        var wi:Double = weight / (22.0 * pow(height, 2));
        if (wi >= 1.0){
            wi = 1.0
        }
        return 14.89 * alb + 41.7 * wi
    }
    
    private func calcPredicted30DDA() -> Double? {
        let sigma = 0.0
        return 1.0 / (1.0 + exp(sigma))
    }
    
    private func calcPredicted30DMALE() -> Double? {
        let sigma = 0.0
        return 1.0 / (1.0 + exp(sigma))
    }
    
    private func calcPredicted2YOS() -> Double? {
        let sigma = 0.0;
        return pow(twoYearOSH0Coeff, exp(sigma))
    }
    
    private func calcPredicted2YAFS()->Double? {
        let sigma = 0.0;
        return pow(twoYearAFSH0Coeff, exp(sigma))
    }
    
    private func classifyGNRI() -> GNRIRisk? {
        guard let gnri = self.gnri else {
            return nil
        }
        switch gnri{
        case 98.0...Double.infinity:
            return GNRIRisk.noRisk
        case 92.0..<98.0:
            return GNRIRisk.low
        case 82.0..<92.0:
            return GNRIRisk.moderate
        case 0.0..<82.0:
            return GNRIRisk.major
        default:
            return nil
        }
    }
    
    private mutating func classifyOS() -> TwoYearOSRisk? {
        guard let os = self.predicted2YOS else {
            return nil
        }
        switch os{
        case 0.70...1.0:
            return TwoYearOSRisk.low
        case 0.50..<0.70:
            return TwoYearOSRisk.medium
        case 0.0..<0.50:
            return TwoYearOSRisk.high
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

