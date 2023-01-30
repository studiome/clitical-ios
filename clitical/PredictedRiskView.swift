//
//  PredictedRiskView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/27.
//

import SwiftUI
import CLPatientData

struct PredictedRiskView: View {
    @State var risk: PatientRisk?
    var body: some View {
        List{
            Section(header: Text("GNRI")){
                Text(String(format: "%.1f", risk!.gnri!))
                Text(LocalizedStringKey(risk!.gnriRisk!.label))
            }
            Section(header: Text("30 Day")){
                Text(String(format: "%.1f", risk!.predicted30DDeathOrAmputation! * 100.0))
                Text(String(format: "%.1f", risk!.predicted30DMALE! * 100.0))
            }
            Section(header: Text("2 Year")){
                Text(String(format: "%.0f", risk!.predicted2YOS! * 100.0))
                Text(LocalizedStringKey(risk!.predicted2YOSRisk!.label))
                Text(String(format: "%.0f", risk!.predicted2YAFS! * 100.0))
            }
        }
    }
}

extension GNRIRisk{
    var label: String{
        switch self{
        case .noRisk: return "GNRINoRisk"
        case .low: return "GNRILowRisk"
        case .moderate: return "GNRIModerateRisk"
        case .major: return "GNRIMajorRisk"
        }
    }
}

extension TwoYearOSRisk{
    var label: String{
        switch self{
        case .low: return "2YOSLowRisk"
        case .medium: return "2YOSMediumRisk"
        case .high: return "2YOSHighRisk"
        }
    }
}

struct PredictedRiskView_Previews: PreviewProvider {
    static var previews: some View {
        PredictedRiskView(risk: PatientRisk(
            of: createTestData(patientData: PatientData())))
        .environment(\.locale, .init(identifier: "ja"));
    }
}

private func createTestData(patientData: PatientData) -> PatientData {
    patientData.age = 65
    patientData.height = 150.0
    patientData.weight = 50.0
    patientData.alb = 4.0
    patientData.hasAILesion = true
    return patientData
}
