//
//  IntendedUse.swift
//  clitical-ios
//

import SwiftUI

/// Versioned record of the reader's acknowledgement of the intended-use notice.
enum IntendedUseDisclaimer {
    static let storageKey = "intended_use_disclaimer_version"

    /// Bump whenever the notice's wording changes materially, so that an
    /// acknowledgement of the older wording no longer counts.
    /// `cliticalUITests` passes this value as a launch argument to start past
    /// the notice; keep the two in sync.
    static let currentVersion = "2026-08"
}

/// Shows the intended-use notice in place of the app until it is acknowledged.
/// The app prints post-operative mortality figures, so what it is — a
/// calculator of published models for clinicians — and what it is not — a
/// medical device that diagnoses or treats — has to be stated before the first
/// value appears, not only in Settings.
struct IntendedUseGate<Content: View>: View {
    @AppStorage(IntendedUseDisclaimer.storageKey) private var acknowledgedVersion = ""

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        if acknowledgedVersion == IntendedUseDisclaimer.currentVersion {
            content
        } else {
            IntendedUseDisclaimerView {
                acknowledgedVersion = IntendedUseDisclaimer.currentVersion
            }
        }
    }
}

struct IntendedUseDisclaimerView: View {
    @EnvironmentObject private var localization: LocalizationManager

    let onAcknowledge: () -> Void

    @State private var isShowingTerms = false

    /// One section per point, keyed by its title so the body string is simply
    /// the title key plus `Body`, as elsewhere in the app.
    private struct Point: Identifiable {
        let id: String
        let symbol: String

        var title: LocalizedStringKey { LocalizedStringKey(id) }
        var detail: LocalizedStringKey { LocalizedStringKey(id + "Body") }
    }

    private let points: [Point] = [
        Point(id: "DisclaimerIntendedUser", symbol: "stethoscope"),
        Point(id: "DisclaimerNotADevice", symbol: "shield.lefthalf.filled"),
        Point(id: "DisclaimerValues", symbol: "function"),
        Point(id: "DisclaimerPopulation", symbol: "chart.bar.doc.horizontal"),
        Point(id: "DisclaimerResponsibility", symbol: "person.text.rectangle"),
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    header
                }
                ForEach(points) { point in
                    Section {
                        Text(point.detail)
                            .font(.callout)
                    } header: {
                        Label(point.title, systemImage: point.symbol)
                    }
                }
                Section {
                    Button {
                        isShowingTerms = true
                    } label: {
                        Label("DisclaimerReadTerms", systemImage: "doc.text")
                    }
                }
            }
            .navigationTitle(Text(verbatim: localization.string(forKey: "DisclaimerTitle")))
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                acknowledgeBar
            }
            .sheet(isPresented: $isShowingTerms) {
                SafariView(url: AppInfo.legalURL(for: .terms, language: localization.language))
                    .ignoresSafeArea()
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8.0) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36.0))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
            Text("DisclaimerHeadline")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8.0)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("intendedUseNotice")
    }

    private var acknowledgeBar: some View {
        VStack(spacing: 8.0) {
            Button(action: onAcknowledge) {
                Text("DisclaimerAcknowledge")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 28.0)
                    .foregroundStyle(Color.prominentButtonLabel)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("acknowledgeDisclaimer")
            Text("DisclaimerAcknowledgeFooter")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.bar)
    }
}
