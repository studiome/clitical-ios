//
//  cliticalApp.swift
//  clitical
//
//  Created by kmiyahara on 2022/12/20.
//

import SwiftUI
import CLPatientData

@main
struct CliticalApp: App {
    @StateObject private var localization = LocalizationManager()
    @StateObject private var patientData = PatientData()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(patientData)
                .environmentObject(localization)
                .environment(\.locale, localization.locale)
                .id(localization.language)
        }
    }
}
