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
        if (risk == nil){
            Text("AnErrorOccured")
        }else{
            List{
                Section(header: Text("GNRI")){
                    VStack{
                        Text("GeriatricNutritionalRiskIndex").padding(4.0)
                        if(risk!.gnri == nil){
                            Text("---").padding(8.0)
                        }else{
                            Text("\(risk!.gnri!, specifier: "%.1f")")
                                .padding(8.0)
                            
                        }
                        if(risk!.gnriRisk == nil){
                            Text("---").padding(8.0)
                        }else{
                            Text(LocalizedStringKey(risk!.gnriRisk!.label)).padding(8.0)
                        }
                    }.frame(maxWidth: .infinity, alignment: .center)
                }
                Section(header: Text("30DayPrediction")){
                    VStack{
                        Text("30DDeathOrAmputation").padding(4.0)
                        if(risk!.predicted30DDeathOrAmputation == nil){
                            Text("---").padding(8.0)
                        }else{
                            Text("\(risk!.predicted30DDeathOrAmputation! * 100.0, specifier: "%.1f")%").padding(8.0)
                        }
                    }.frame(maxWidth: .infinity, alignment: .center)
                    VStack{
                        Text("30DMALE").padding(4.0)
                        if(risk!.predicted30DMALE == nil){
                            Text("---").padding(8.0)
                        }else{
                            Text("\(risk!.predicted30DMALE! * 100.0, specifier: "%.1f")%").padding(8.0)
                        }
                    }.frame(maxWidth: .infinity, alignment: .center)
                }
                Section(header: Text("2YearPrediction")){
                    VStack{
                        Text("2YOS").padding(4.0)
                        if(risk!.predicted2YOS == nil){
                            Text("---").padding(8.0)
                        }else{
                            Text("\(risk!.predicted2YOS!*100.0, specifier: "%.0f")%").padding(8.0)
                        }
                        if(risk!.predicted2YOSRisk == nil){
                            Text("---").padding(8.0)
                        }else{
                            Text(LocalizedStringKey(risk!.predicted2YOSRisk!.label)).padding(8.0)
                        }
                    }.frame(maxWidth: .infinity, alignment: .center)
                    VStack{
                        Text("2YAFS").padding(4.0)
                        if(risk!.predicted2YAFS == nil){
                            Text("---").padding(8.0)
                        }else{
                            Text("\(risk!.predicted2YAFS!*100.0, specifier: "%.0f")%").padding(8.0)
                        }
                    }.frame(maxWidth: .infinity, alignment: .center)
                }
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
        PredictedRiskView(risk:nil)
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
