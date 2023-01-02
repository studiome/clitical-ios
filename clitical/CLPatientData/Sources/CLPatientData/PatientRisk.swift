//
//  PatientRisk.swift
//  
//
//  Created by kmiyahara on 2023/01/02.
//

import Foundation
public struct PatientRisk{
    public var gnri: Double?
    public var gnriRisk: GNRIRisk?
    public var predicted30DDeathOrAmputation: Double?
    public var predicted30DMALE: Double?
    public var predicted2YOS: Double?
    public var predicted2YOSRisk: TwoYearOSRisk?
    public var predicted2YAFS: Double?
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

