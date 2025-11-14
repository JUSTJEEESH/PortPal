import Foundation
import SwiftUI

enum TimerState: String, Codable {
    case settingSailSoon
    case allAboard
    case seasTheDay
    case landHo
    case explorationTime
    case bonVoyage
    case untilNextTime
    case cruiseComplete

    var displayName: String {
        switch self {
        case .settingSailSoon: return "Setting Sail Soon"
        case .allAboard: return "All Aboard!"
        case .seasTheDay: return "Seas the Day"
        case .landHo: return "Land Ho!"
        case .explorationTime: return "Exploration Time"
        case .bonVoyage: return "Bon Voyage"
        case .untilNextTime: return "Until Next Time"
        case .cruiseComplete: return "Cruise Complete"
        }
    }

    var colorTheme: TimerColorTheme {
        switch self {
        case .settingSailSoon: return .purple
        case .allAboard: return .oceanTeal
        case .seasTheDay: return .cyan
        case .landHo: return .caribbeanCyan
        case .explorationTime: return .sunsetOrange
        case .bonVoyage: return .hotPink
        case .untilNextTime: return .coralRed
        case .cruiseComplete: return .steelGray
        }
    }
}

enum TimerColorTheme {
    case purple
    case oceanTeal
    case cyan
    case caribbeanCyan
    case sunsetOrange
    case hotPink
    case coralRed
    case steelGray

    // Return Color from PortPal color palette
    var color: Color {
        switch self {
        case .purple: return Color(red: 0.6, green: 0.3, blue: 0.8)
        case .oceanTeal: return .oceanTeal
        case .cyan: return Color(red: 0.2, green: 0.7, blue: 0.9)
        case .caribbeanCyan: return .caribbeanCyan
        case .sunsetOrange: return .sunsetOrange
        case .hotPink: return .hotPink
        case .coralRed: return .coralRed
        case .steelGray: return .steelGray
        }
    }

    // Maintain backward compatibility with RGB arrays for gradient animations
    var gradient: [Double] {
        return color.rgbArray
    }
}

enum ExplorationUrgency {
    case relaxed      // 2+ hours remaining
    case moderate     // 30min - 2 hours
    case urgent       // 15min - 30min
    case critical     // <15 minutes

    // Use PortPal color palette for urgency states
    var color: Color {
        switch self {
        case .relaxed: return .urgencyAllGood          // Caribbean Cyan (#00D4AA)
        case .moderate: return .urgencyStayAlert       // Sunshine Yellow (#FFD54F)
        case .urgent: return .urgencyDepartingSoon     // Sunset Orange (#FF6B35)
        case .critical: return .urgencyReturnNow       // Coral Red (#FF1744)
        }
    }

    // Maintain backward compatibility with RGB arrays
    var colorArray: [Double] {
        return color.rgbArray
    }

    var message: String {
        switch self {
        case .relaxed: return "Enjoy your time!"
        case .moderate: return "Start heading back soon"
        case .urgent: return "Time to head back!"
        case .critical: return "GET BACK NOW!"
        }
    }
}
