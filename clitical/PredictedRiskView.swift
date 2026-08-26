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
                    RiskRow(icon: "bandage",
                            title: "30DMALE") {
                        percentText(risk.predicted30DMALE, fractionDigits: 1)
                    }
                }
                Section(header: Text("2YearPrediction")) {
                    RiskRow(icon: "heart.text.square",
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
                    RiskRow(icon: "fork.knife",
                            title: "GeriatricNutritionalRiskIndex") {
                        valueText(risk.gnri, fractionDigits: 1)
                        riskLabelText(risk.gnriRisk?.label,
                                      color: risk.gnriRisk?.color)
                    }
                }
                // The figures above are the part of the app most likely to be
                // read out of context, so what they are — and are not —
                // is restated beside them rather than left to Settings.
                Section {
                    Label {
                        Text("DisclaimerShortNotice")
                            .font(.footnote)
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                    .foregroundStyle(.secondary)
                    .accessibilityElement(children: .combine)
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

/// Severity colours. `.green` and `.orange` reach only about 2:1 against a
/// white list background — below the 3:1 the HIG asks for even at large text
/// sizes — so light mode uses darker variants. Dark mode keeps the system
/// colours, which are already legible on a dark background.
private extension Color {
    static let riskLow = adaptive(light: UIColor(red: 0.08, green: 0.50, blue: 0.24, alpha: 1),
                                  dark: .systemGreen)
    static let riskMedium = adaptive(light: UIColor(red: 0.60, green: 0.36, blue: 0.00, alpha: 1),
                                     dark: .systemOrange)
    static let riskHigh = adaptive(light: UIColor(red: 0.70, green: 0.15, blue: 0.12, alpha: 1),
                                   dark: .systemRed)

    private static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? dark : light })
    }
}

private extension TwoYearOSRisk {
    var color: Color {
        switch self {
        case .low: return .riskLow
        case .medium: return .riskMedium
        case .high: return .riskHigh
        }
    }
}

private extension GNRIRisk {
    var color: Color {
        switch self {
        case .noRisk: return .riskLow
        case .low, .moderate: return .riskMedium
        case .major: return .riskHigh
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

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: isAccessibilitySize ? .leading : .center, spacing: 4.0) {
            header
            content
                .frame(maxWidth: .infinity,
                       alignment: isAccessibilitySize ? .leading : .center)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        // One VoiceOver stop per risk item: title then value, instead of
        // the decorative icon, title, and value as separate elements.
        .accessibilityElement(children: .combine)
    }

    private var isAccessibilitySize: Bool { dynamicTypeSize.isAccessibilitySize }

    @ViewBuilder
    private var header: some View {
        if isAccessibilitySize {
            // The symbol is decorative and only echoes the title, so at these
            // sizes the width goes to the words instead.
            titleText
        } else {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                    .accessibilityHidden(true)
                titleText
            }
        }
    }

    private var titleText: some View {
        Text(title)
            .padding(4.0)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
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
    patientData.sex = .female
    patientData.age = 65
    patientData.height = 150.0
    patientData.weight = 50.0
    patientData.alb = 4.0
    patientData.hasAILesion = true
    return patientData
}
