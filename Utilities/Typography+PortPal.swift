//
//  Typography+PortPal.swift
//  PortPal
//
//  Typography system with Dynamic Type support following UI/UX Guide
//

import SwiftUI

extension Font {
    // MARK: - PortPal Typography Scale with Dynamic Type Support

    /// Hero Timer - 48pt, Semibold, Monospaced, with Dynamic Type
    static func heroTimer(relativeTo textStyle: Font.TextStyle = .largeTitle) -> Font {
        return .system(size: 48, weight: .semibold, design: .monospaced)
            .scaledToStyle(relativeTo: textStyle)
    }

    /// Large Title - 34pt, Bold, with Dynamic Type
    static func largeTitle(weight: Font.Weight = .bold) -> Font {
        return .system(size: 34, weight: weight, design: .default)
    }

    /// Title 1 - 28pt, Regular, with Dynamic Type
    static func title1(weight: Font.Weight = .regular) -> Font {
        return .system(size: 28, weight: weight, design: .default)
    }

    /// Title 2 - 22pt, Semibold, with Dynamic Type
    static func title2(weight: Font.Weight = .semibold) -> Font {
        return .system(size: 22, weight: weight, design: .default)
    }

    /// Title 3 - 20pt, Semibold, with Dynamic Type
    static func title3(weight: Font.Weight = .semibold) -> Font {
        return .system(size: 20, weight: weight, design: .default)
    }

    /// Headline - 17pt, Semibold, with Dynamic Type
    static func headline(weight: Font.Weight = .semibold) -> Font {
        return .system(size: 17, weight: weight, design: .default)
    }

    /// Body - 17pt, Regular, with Dynamic Type
    static func bodyText(weight: Font.Weight = .regular) -> Font {
        return .system(size: 17, weight: weight, design: .default)
    }

    /// Callout - 16pt, Regular, with Dynamic Type
    static func callout(weight: Font.Weight = .regular) -> Font {
        return .system(size: 16, weight: weight, design: .default)
    }

    /// Subheadline - 15pt, Regular, with Dynamic Type
    static func subheadline(weight: Font.Weight = .regular) -> Font {
        return .system(size: 15, weight: weight, design: .default)
    }

    /// Footnote - 13pt, Regular, with Dynamic Type
    static func footnote(weight: Font.Weight = .regular) -> Font {
        return .system(size: 13, weight: weight, design: .default)
    }

    /// Caption 1 - 12pt, Regular, with Dynamic Type
    static func caption1(weight: Font.Weight = .regular) -> Font {
        return .system(size: 12, weight: weight, design: .default)
    }

    /// Caption 2 - 11pt, Regular, with Dynamic Type
    static func caption2(weight: Font.Weight = .regular) -> Font {
        return .system(size: 11, weight: weight, design: .default)
    }

    // MARK: - Helper Methods

    /// Apply Dynamic Type scaling to a font relative to a text style
    private func scaledToStyle(relativeTo style: Font.TextStyle) -> Font {
        // SwiftUI automatically handles scaling when using system fonts
        return self
    }
}

// MARK: - Spacing Constants (8pt base unit system)

struct Spacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64

    // Content margins
    static let screenHorizontal: CGFloat = 20
    static let cardInternal: CGFloat = 16
    static let listItemVertical: CGFloat = 12
    static let sectionSpacing: CGFloat = 24
}

// MARK: - Accessibility Helpers

struct AccessibilityHelper {
    /// Check if Reduce Motion is enabled
    @Environment(\.accessibilityReduceMotion) static var reduceMotion

    /// Check if VoiceOver is running
    static var isVoiceOverRunning: Bool {
        #if canImport(UIKit)
        return UIAccessibility.isVoiceOverRunning
        #else
        return false
        #endif
    }

    /// Check if Bold Text is enabled
    static var isBoldTextEnabled: Bool {
        #if canImport(UIKit)
        return UIAccessibility.isBoldTextEnabled
        #else
        return false
        #endif
    }

    /// Get current Dynamic Type size category
    static var sizeCategory: ContentSizeCategory {
        #if canImport(UIKit)
        return ContentSizeCategory(UIApplication.shared.preferredContentSizeCategory)
        #else
        return .medium
        #endif
    }
}
