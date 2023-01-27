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
                //Text(risk.gnriRisk)
            }
            Section(header: Text("30 Day")){
                Text(String(format: "%.1f", risk!.predicted30DDeathOrAmputation! * 100.0))
                Text(String(format: "%.1f", risk!.predicted30DMALE! * 100.0))
            }
            Section(header: Text("2 Year")){
                Text(String(format: "%.0f", risk!.predicted2YOS! * 100.0))
                //Text(risk.predicted2YOSRisk)
                Text(String(format: "%.0f", risk!.predicted2YAFS! * 100.0))
            }
        }
    }
}

struct PredictedRiskView_Previews: PreviewProvider {
    static var previews: some View {
        PredictedRiskView(risk:PatientRisk(
            of: createTestData(patientData: PatientData())))
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
