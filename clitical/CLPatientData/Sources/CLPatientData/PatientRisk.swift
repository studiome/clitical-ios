//
//  PatientRisk.swift
//  
//
//  Created by kmiyahara on 2023/01/02.
//

public struct PatientRisk{
    var gnri: Double? {
        return calcGNRI()
    }
    lazy var gnriRisk: GNRIRisk? = classifyGNRI()
    var predicted30DDeathOrAmputation: Double? {
        return calcPredicted30DDA()
    }// 0.0 ... 1.0
    var predicted30DMALE: Double?{
        return calcPredicted30DMALE()
    } // 0.0 ... 1.0
    var predicted2YOS: Double?{
        return calcPredicted2YOS()
    } // 0.0 ... 1.0
    lazy var predicted2YOSRisk: TwoYearOSRisk? = classifyOS()
    var predicted2YAFS: Double?{
        return calcPredicted2YAFS()
    }// 0.0 ... 1.0
    var patientData: PatientData
    
    init(ofPatient patientData: PatientData){
        self.patientData = patientData;
    }
    
    private func calcGNRI() -> Double?{
        return nil
    }
    
    private func calcPredicted30DDA() -> Double?{
        return nil
    }
    
    private func calcPredicted30DMALE() -> Double?{
        return nil
    }
    
    private func calcPredicted2YOS() -> Double?{
        return nil
    }
    
    private func calcPredicted2YAFS()->Double?{
        return nil
    }
    
    private func classifyGNRI() -> GNRIRisk?{
        guard let gnri = self.gnri else{
            return nil
        }
        switch gnri{
        case 98.0...Double.infinity:
            return GNRIRisk.noRisk
        case 92.0..<98.0:
            return GNRIRisk.low
        case 82.0..<92.0:
            return GNRIRisk.medium
        case 0.0..<82.0:
            return GNRIRisk.major
        default:
            return nil
        }
    }
    
    private func classifyOS() -> TwoYearOSRisk?{
        guard let os = self.predicted2YOS else{
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

public enum GNRIRisk{
    case noRisk
    case low
    case medium
    case major
}

public enum TwoYearOSRisk{
    case low
    case medium
    case high
}

