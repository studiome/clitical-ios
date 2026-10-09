//
//  Color+ProminentButton.swift
//  clitical-ios
//

import SwiftUI

/// Label colour for `.borderedProminent` buttons. The style fills with the
/// accent colour and draws its label in white, which drops to roughly 1.7:1
/// against the light accent used in dark mode; the background colour tracks
/// the appearance and stays legible in both.
extension Color {
    static var prominentButtonLabel: Color { Color(uiColor: .systemBackground) }
}
