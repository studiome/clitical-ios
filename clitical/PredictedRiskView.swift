//
//  PredictedRiskView.swift
//  clitical-ios
//
//  Created by kmiyahara on 2023/01/27.
//

import SwiftUI
import CLPatientData

struct PredictedRiskView: View {
    @EnvironmentObject var localization: LocalizationManager
    let risk: PatientRisk?
    let showsNavigationTitle: Bool

    init(risk: PatientRisk?, showsNavigationTitle: Bool = true) {
        self.risk = risk
        self.showsNavigationTitle = showsNavigationTitle
    }

    var body: some View {
        if let risk {
            List {
                Section(header: Text("30DayPrediction"),
                        footer: Text("MALEDescription").font(.caption)) {
                    RiskRow(icon: "staroflife",
                            title: "30DDeathOrAmputation") {
                        percentText(risk.predicted30DDeathOrAmputation,
                                    fractionDigits: 1)
                    }
                    RiskRow(icon: "bed.double",
                            title: "30DMALE") {
                        percentText(risk.predicted30DMALE, fractionDigits: 1)
                    }
                }
                Section(header: Text("2YearPrediction")) {
                    RiskRow(icon: "staroflife",
                            title: "2YOS") {
                        percentText(risk.predicted2YOS, fractionDigits: 0)
                        riskLabelText(risk.predicted2YOSRisk?.label,
                                      color: risk.predicted2YOSRisk?.color)
                    }
                    RiskRow(icon: "figure.walk",
                            title: "2YAFS") {
                        percentText(risk.predicted2YAFS, fractionDigits: 0)
                    }
                }
                Section(header: Text("GNRI")) {
                    RiskRow(icon: "flame",
                            title: "GeriatricNutritionalRiskIndex") {
                        valueText(risk.gnri, fractionDigits: 1)
                        riskLabelText(risk.gnriRisk?.label,
                                      color: risk.gnriRisk?.color)
                    }
                }
            }
            .conditionalNavigationTitle(
                showsNavigationTitle,
                title: localization.string(forKey: "RiskViewTitle")
            )
        } else {
            VStack(spacing: 12.0) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .accessibilityHidden(true)
                Text("AnErrorOccured")
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(.secondary)
            .padding()
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
    private func riskLabelText(_ label: String?, color: Color?) -> some View {
        if let label {
            // The severity color is supplementary: the label text itself
            // states the risk level, so color is never the sole indicator.
            Text(LocalizedStringKey(label))
                .font(.title2)
                .foregroundColor(color ?? .primary)
        } else {
            Text("---")
        }
    }
}

private extension View {
    @ViewBuilder
    func conditionalNavigationTitle(_ isVisible: Bool, title: String) -> some View {
        if isVisible {
            self
                .navigationTitle(Text(verbatim: title))
                .navigationBarTitleDisplayMode(.inline)
        } else {
            self
        }
    }
}

private extension TwoYearOSRisk {
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

private extension GNRIRisk {
    var color: Color {
        switch self {
        case .noRisk: return .green
        case .low, .moderate: return .orange
        case .major: return .red
        }
    }
}

/// A titled risk item: an icon with a headline, followed by the value views.
/// The headline stays in the primary label color — colored text on iOS reads
/// as interactive — and only the decorative icon carries the accent color.
private struct RiskRow<Content: View>: View {
    let icon: String
    let title: LocalizedStringKey
    @ViewBuilder let content: Content

    var body: some View {
        VStack {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                    .accessibilityHidden(true)
                Text(title)
                    .padding(4.0)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .center)
        // One VoiceOver stop per risk item: title then value, instead of
        // the decorative icon, title, and value as separate elements.
        .accessibilityElement(children: .combine)
    }
}

#Preview("Error") {
    PredictedRiskView(risk: nil)
        .environmentObject(LocalizationManager())
        .environment(\.locale, .init(identifier: "ja"))
}

#Preview("Result") {
    PredictedRiskView(risk: PatientRisk(of: previewPatientData()))
        .environmentObject(LocalizationManager())
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
