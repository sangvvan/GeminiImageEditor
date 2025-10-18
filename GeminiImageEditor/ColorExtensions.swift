//
//  ColorExtensions.swift
//  GeminiImageEditor
//
//  Created by AI Assistant
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // MARK: - Adaptive Colors for Dark Mode
    
    /// Adaptive background colors that work in both light and dark modes
    static let adaptiveCardBackground = Color(UIColor.systemBackground)
    static let adaptiveSecondaryBackground = Color(UIColor.secondarySystemBackground)
    static let adaptiveTertiaryBackground = Color(UIColor.tertiarySystemBackground)
    
    /// Feature card colors that adapt to dark mode
    /// Note: These will fallback to system colors if custom colors aren't defined in Assets
    static let promptToImageBackground = Color(UIColor.systemBackground)
    static let promptToVideoBackground = Color(UIColor.systemBackground)
    static let faceSwapBackground = Color(UIColor.systemBackground)
    
    // Fallback colors if custom colors aren't defined
    static func adaptiveFeatureBackground(for feature: String) -> Color {
        switch feature {
        case "promptToImage":
            return Color(UIColor.systemBackground)
        case "promptToVideo":
            return Color(UIColor.systemBackground)
        case "faceSwap":
            return Color(UIColor.systemBackground)
        default:
            return Color(UIColor.systemBackground)
        }
    }
}
