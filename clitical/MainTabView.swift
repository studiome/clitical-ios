//
//  MainTabView.swift
//  clitical-ios
//
//  Bottom tab navigation that replaces the Flutter/Android hamburger menu:
//  Risk calculation, References, and Settings. Per the HIG, tabs are for
//  content areas, so settings-like items (language, terms, app info) are
//  grouped in a single Settings tab instead of holding tabs of their own.
//

import SwiftUI

// MARK: - MainTabView

struct MainTabView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab: AppSection = .riskCalculation
    @State private var selectedSection: AppSection? = .riskCalculation

    var body: some View {
        if #available(iOS 18.0, *) {
            adaptableTabRoot
        } else if horizontalSizeClass == .regular {
            NavigationSplitView {
                sidebar
            } detail: {
                splitViewDetail
            }
        } else {
            tabRoot
        }
    }

    @available(iOS 18.0, *)
    private var adaptableTabRoot: some View {
        TabView(selection: $selectedTab) {
            Tab("RiskCalculationTab", systemImage: "chart.line.uptrend.xyaxis", value: AppSection.riskCalculation) {
                RootContentView()
            }
            Tab("References", systemImage: "doc.text", value: AppSection.references) {
                ReferencesView()
            }
            Tab("Settings", systemImage: "gearshape", value: AppSection.settings) {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }

    @ViewBuilder
    private var sidebar: some View {
        if #available(iOS 17.0, *) {
            List(AppSection.allCases, selection: $selectedSection) { section in
                NavigationLink(value: section) {
                    Label(section.titleKey, systemImage: section.symbolName)
                }
                .accessibilityIdentifier(section.rawValue)
            }
            .adaptiveSidebarStyle()
            .navigationTitle(Text(verbatim: AppInfo.name))
        } else {
            List {
                ForEach(AppSection.allCases) { section in
                    Button {
                        selectedSection = section
                    } label: {
                        Label(section.titleKey, systemImage: section.symbolName)
                    }
                    .accessibilityIdentifier(section.rawValue)
                    .foregroundStyle(.primary)
                    .listRowBackground(
                        selectedSection == section ? Color.accentColor.opacity(0.12) : nil
                    )
                }
            }
            .navigationTitle(Text(verbatim: AppInfo.name))
        }
    }

    private var splitViewDetail: some View {
        ZStack {
            splitViewSection(.riskCalculation) {
                RootContentView()
            }
            splitViewSection(.references) {
                ReferencesView()
            }
            splitViewSection(.settings) {
                SettingsView()
            }
        }
    }

    private func splitViewSection<Content: View>(
        _ section: AppSection,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let isSelected = selectedSection == section
        return content()
            .opacity(isSelected ? 1 : 0)
            .allowsHitTesting(isSelected)
            .accessibilityHidden(!isSelected)
    }

    private var tabRoot: some View {
        TabView(selection: $selectedTab) {
            RootContentView()
                .tabItem {
                    Label("RiskCalculationTab", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(AppSection.riskCalculation)
            ReferencesView()
                .tabItem {
                    Label("References", systemImage: "doc.text")
                }
                .tag(AppSection.references)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(AppSection.settings)
        }
    }
}

@available(iOS 17.0, *)
private extension View {
    func adaptiveSidebarStyle() -> some View {
        contentMargins(.horizontal, 8, for: .scrollContent)
    }
}

private enum AppSection: String, CaseIterable, Identifiable {
    case riskCalculation
    case references
    case settings

    var id: Self { self }

    var titleKey: LocalizedStringKey {
        switch self {
        case .riskCalculation: "RiskCalculationTab"
        case .references: "References"
        case .settings: "Settings"
        }
    }

    var symbolName: String {
        switch self {
        case .riskCalculation: "chart.line.uptrend.xyaxis"
        case .references: "doc.text"
        case .settings: "gearshape"
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(LocalizationManager())
        .environment(\.locale, .init(identifier: "ja"))
}
