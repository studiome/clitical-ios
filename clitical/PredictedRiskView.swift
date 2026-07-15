//
//  PredictedRiskView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/27.
//

import SwiftUI
import CLPatientData

struct PredictedRiskView: View {
    let risk: PatientRisk?

    var body: some View {
        if let risk {
            List {
                Section(header: Text("30DayPrediction"),
                        footer: Text("MALEDescription").font(.caption)) {
                    RiskRow(icon: "staroflife",
                            title: "30DDeathOrAmputation",
                            color: .blue) {
                        percentText(risk.predicted30DDeathOrAmputation,
                                    fractionDigits: 1)
                    }
                    RiskRow(icon: "bed.double",
                            title: "30DMALE",
                            color: .blue) {
                        percentText(risk.predicted30DMALE, fractionDigits: 1)
                    }
                }
                Section(header: Text("2YearPrediction")) {
                    RiskRow(icon: "staroflife",
                            title: "2YOS",
                            color: .blue) {
                        percentText(risk.predicted2YOS, fractionDigits: 0)
                        riskLabelText(risk.predicted2YOSRisk?.label)
                    }
                    RiskRow(icon: "figure.walk",
                            title: "2YAFS",
                            color: .blue) {
                        percentText(risk.predicted2YAFS, fractionDigits: 0)
                    }
                }
                Section(header: Text("GNRI")) {
                    RiskRow(icon: "flame",
                            title: "GeriatricNutritionalRiskIndex",
                            color: .red) {
                        valueText(risk.gnri, fractionDigits: 1)
                        riskLabelText(risk.gnriRisk?.label)
                    }
                }
            }
            .navigationTitle("RiskViewTitle")
            .navigationBarTitleDisplayMode(.inline)
        } else {
            Text("AnErrorOccured")
        }
    }

    @ViewBuilder
    private func percentText(_ value: Double?, fractionDigits: Int) -> some View {
        if let value {
            Text(value, format: .percent.precision(.fractionLength(fractionDigits)))
                .font(.title)
        } else {
            Text("---")
        }
    }

    @ViewBuilder
    private func valueText(_ value: Double?, fractionDigits: Int) -> some View {
        if let value {
            Text(value, format: .number.precision(.fractionLength(fractionDigits)))
                .font(.title)
        } else {
            Text("---")
        }
    }

    @ViewBuilder
    private func riskLabelText(_ label: String?) -> some View {
        if let label {
            Text(LocalizedStringKey(label))
                .font(.title2)
        } else {
            Text("---")
        }
    }
}

/// A titled risk item: an icon with a headline, followed by the value views.
private struct RiskRow<Content: View>: View {
    let icon: String
    let title: LocalizedStringKey
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .padding(4.0)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundColor(color)
            content
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview("Error") {
    PredictedRiskView(risk: nil)
        .environment(\.locale, .init(identifier: "ja"))
}

#Preview("Result") {
    PredictedRiskView(risk: PatientRisk(of: previewPatientData()))
        .environment(\.locale, .init(identifier: "ja"))
}

private func previewPatientData() -> PatientData {
    var patientData = PatientData()
    patientData.age = 65
    patientData.height = 150.0
    patientData.weight = 50.0
    patientData.alb = 4.0
    patientData.hasAILesion = true
    return patientData
}
