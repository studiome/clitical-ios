//
//  AboutView.swift
//  clitical-ios
//

import SwiftUI

/// Detail screen behind the Settings > About row: what the app is for, what it
/// predicts, how the values are derived, where the models come from and what
/// they do not cover. Guideline 1.4.1 asks a medical app to disclose its data
/// and methodology, so this screen — not an external web page — is where that
/// disclosure lives.
struct AboutView: View {
    private struct Prediction: Identifiable {
        let id: String
        let icon: String
        var title: LocalizedStringKey { LocalizedStringKey(id) }
    }

    /// The predicted indices, mirroring the order and symbols used on the
    /// results screen so the two read as the same list.
    private let predictions: [Prediction] = [
        Prediction(id: "30DDeathOrAmputation", icon: "staroflife"),
        Prediction(id: "30DMALE", icon: "bandage"),
        Prediction(id: "2YOS", icon: "heart.text.square"),
        Prediction(id: "2YAFS", icon: "figure.walk"),
        Prediction(id: "GeriatricNutritionalRiskIndex", icon: "fork.knife"),
    ]

    var body: some View {
        List {
            Section {
                header
            }
            Section(header: Text("AboutOverview")) {
                Text("AboutOverviewBody")
                    .font(.callout)
            }
            Section(header: Text("AboutIntendedUse")) {
                Text("AboutIntendedUseBody")
                    .font(.callout)
            }
            Section(header: Text("AboutPredictions"),
                    footer: Text("AboutPredictionsFooter")) {
                ForEach(predictions) { prediction in
                    Label {
                        Text(prediction.title)
                            .font(.callout)
                    } icon: {
                        Image(systemName: prediction.icon)
                            .foregroundStyle(Color.accentColor)
                    }
                    // The symbol only echoes the title, so VoiceOver reads
                    // the row as a single label.
                    .accessibilityElement(children: .combine)
                }
            }
            Section(header: Text("AboutMethodology")) {
                Text("AboutMethodologyBody")
                    .font(.callout)
            }
            Section(header: Text("AboutModelSource")) {
                Text("AboutModelSourceBody")
                    .font(.callout)
            }
            Section(header: Text("AboutLimitations")) {
                Text("AboutLimitationsBody")
                    .font(.callout)
            }
            Section(header: Text("AboutPrivacy")) {
                Text("AboutPrivacyBody")
                    .font(.callout)
            }
            Section(header: Text("AboutDisclaimer")) {
                Text("AboutDisclaimerBody")
                    .font(.callout)
            }
            Section(header: Text("AboutCredits")) {
                creditRow(label: "AboutPublisher", value: "AboutPublisherName")
                creditRow(label: "AboutDeveloper", value: "AboutDeveloperName")
                creditRow(label: "AboutVersion", verbatim: AppInfo.version)
                creditRow(label: "AboutBuild", verbatim: AppInfo.build)
            }
        }
        .navigationTitle(Text("About"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 8.0) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.largeTitle)
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
            Text(verbatim: AppInfo.name)
                .font(.title.weight(.semibold))
            Text("AboutTagline")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8.0)
        .accessibilityElement(children: .combine)
    }

    /// A label/value pair. Stacked vertically rather than side by side so long
    /// organisation names stay readable at large Dynamic Type sizes.
    private func creditRow(label: LocalizedStringKey, value: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 2.0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.callout)
        }
        .accessibilityElement(children: .combine)
    }

    private func creditRow(label: LocalizedStringKey, verbatim value: String) -> some View {
        VStack(alignment: .leading, spacing: 2.0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(verbatim: value)
                .font(.callout)
        }
        .accessibilityElement(children: .combine)
    }
}
