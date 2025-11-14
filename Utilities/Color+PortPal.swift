//
//  Color+PortPal.swift
//  PortPal
//
//  Color palette extension following UI/UX Guide specifications
//

import SwiftUI

extension Color {
    // MARK: - Primary Brand Colors (from UI/UX Guide)

    /// Navy Dark (#0A1628) - Primary background, headers, dark elements
    static let navyDark = Color(hex: "#0A1628")

    /// Ocean Teal (#00A5CF) - Accent color, early arrival states, interactive elements
    static let oceanTeal = Color(hex: "#00A5CF")

    /// Caribbean Cyan (#00D4AA) - Success states, "plenty of time" indicator
    static let caribbeanCyan = Color(hex: "#00D4AA")

    /// Sunshine Yellow (#FFD54F) - Warning states, moderate urgency
    static let sunshineYellow = Color(hex: "#FFD54F")

    /// Sunset Orange (#FF6B35) - Urgent states, high priority alerts
    static let sunsetOrange = Color(hex: "#FF6B35")

    /// Coral Red (#FF1744) - Critical states, immediate action required
    static let coralRed = Color(hex: "#FF1744")

    /// Steel Gray (#6B7280) - Secondary text, disabled states, subtle UI elements
    static let steelGray = Color(hex: "#6B7280")

    /// Hot Pink (#E91E63) - Premium cruise line accent, special highlights
    static let hotPink = Color(hex: "#E91E63")

    // MARK: - Urgency State Colors

    /// All Good - 7+ hours remaining (#00D4AA)
    static let urgencyAllGood = caribbeanCyan

    /// Stay Alert - 3-7 hours remaining (#FFD54F)
    static let urgencyStayAlert = sunshineYellow

    /// Departing Soon - 1-3 hours remaining (#FF6B35)
    static let urgencyDepartingSoon = sunsetOrange

    /// Return to Ship NOW - 45min-1hr remaining (#FF1744)
    static let urgencyReturnNow = coralRed

    /// Ship Departed - Past departure time (#6B7280)
    static let urgencyShipDeparted = steelGray

    // MARK: - Semantic Colors

    /// Card background - Dark navy with slight transparency
    static let cardBackground = Color(hex: "#1A2332")

    /// Card border - Subtle gray border
    static let cardBorder = Color(hex: "#2A3342")

    /// Text primary - White for dark backgrounds
    static let textPrimary = Color.white

    /// Text secondary - Steel gray for less important text
    static let textSecondary = steelGray

    /// Success indicator
    static let success = caribbeanCyan

    /// Warning indicator
    static let warning = sunshineYellow

    /// Error/Critical indicator
    static let error = coralRed

    // MARK: - Hex Color Initializer

    /// Initialize a Color from a hex string
    /// - Parameter hex: Hex color string (e.g., "#FF0000" or "FF0000")
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
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - RGB Array Conversion (for backward compatibility)

    /// Convert Color to RGB array [red, green, blue] with values 0.0-1.0
    /// Useful for maintaining compatibility with existing gradient code
    var rgbArray: [Double] {
        #if canImport(UIKit)
        guard let components = UIColor(self).cgColor.components else {
            return [0, 0, 0]
        }
        if components.count >= 3 {
            return [Double(components[0]), Double(components[1]), Double(components[2])]
        }
        return [0, 0, 0]
        #else
        return [0, 0, 0]
        #endif
    }

    /// Create Color from RGB array [red, green, blue] with values 0.0-1.0
    static func fromRGBArray(_ rgb: [Double]) -> Color {
        guard rgb.count >= 3 else { return .black }
        return Color(red: rgb[0], green: rgb[1], blue: rgb[2])
    }
}

// MARK: - Color Theme Helpers

extension Color {
    /// Get urgency color based on time remaining (in seconds)
    static func urgencyColor(for timeRemaining: TimeInterval) -> Color {
        let hours = timeRemaining / 3600

        if hours >= 7 {
            return .urgencyAllGood
        } else if hours >= 3 {
            return .urgencyStayAlert
        } else if hours >= 1 {
            return .urgencyDepartingSoon
        } else if timeRemaining >= 0 {
            return .urgencyReturnNow
        } else {
            return .urgencyShipDeparted
        }
    }

    /// Get urgency message based on time remaining
    static func urgencyMessage(for timeRemaining: TimeInterval) -> String {
        let hours = timeRemaining / 3600

        if hours >= 7 {
            return "Enjoy your time!"
        } else if hours >= 3 {
            return "Keep track of time"
        } else if hours >= 1 {
            return "Start heading back"
        } else if timeRemaining >= 0 {
            return "Return to ship NOW!"
        } else {
            return "Ship has departed"
        }
    }
}
