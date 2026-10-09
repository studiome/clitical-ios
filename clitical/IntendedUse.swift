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
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @ScaledMetric(relativeTo: .headline) private var buttonMinHeight = 28.0

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
                // In a compact-height window (iPhone in landscape) a bottom
                // bar would take a large share of the little height there
                // is, so the acknowledgement scrolls with the notice instead.
                if isCompactHeight {
                    Section {
                        acknowledgeContent
                            .listRowBackground(Color.clear)
                    }
                }
            }
            .navigationTitle(Text("DisclaimerTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                if !isCompactHeight {
                    acknowledgeBar
                }
            }
            .sheet(isPresented: $isShowingTerms) {
                SafariView(url: AppInfo.legalURL(for: .terms))
                    .ignoresSafeArea()
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8.0) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
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

    private var isCompactHeight: Bool { verticalSizeClass == .compact }

    private var acknowledgeBar: some View {
        acknowledgeContent
            .padding()
            .background(.bar)
    }

    private var acknowledgeContent: some View {
        VStack(spacing: 8.0) {
            Button(action: onAcknowledge) {
                Text("DisclaimerAcknowledge")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: buttonMinHeight)
                    .foregroundStyle(Color.prominentButtonLabel)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("acknowledgeDisclaimer")
            Text("DisclaimerAcknowledgeFooter")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}
