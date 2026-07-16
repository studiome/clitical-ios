//
//  cliticalApp.swift
//  clitical
//
//  Created by kmiyahara on 2022/12/20.
//

import SwiftUI

@main
struct CliticalApp: App {
    @StateObject private var localization = LocalizationManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(localization)
                .environment(\.locale, localization.locale)
        }
    }
}
