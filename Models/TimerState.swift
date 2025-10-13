import Foundation

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
        case .allAboard: return .blue
        case .seasTheDay: return .cyan
        case .landHo: return .green
        case .explorationTime: return .orange
        case .bonVoyage: return .pink
        case .untilNextTime: return .red
        case .cruiseComplete: return .gray
        }
    }
}

enum TimerColorTheme {
    case purple, blue, cyan, green, orange, pink, red, gray
    
    var gradient: [Double] {
        switch self {
        case .purple: return [0.6, 0.3, 0.8]
        case .blue: return [0.2, 0.4, 0.8]
        case .cyan: return [0.2, 0.7, 0.9]
        case .green: return [0.2, 0.8, 0.4]
        case .orange: return [1.0, 0.6, 0.2]
        case .pink: return [1.0, 0.4, 0.6]
        case .red: return [0.9, 0.3, 0.3]
        case .gray: return [0.5, 0.5, 0.5]
        }
    }
}

enum ExplorationUrgency {
    case relaxed
    case moderate
    case urgent
    case critical
    
    var color: [Double] {
        switch self {
        case .relaxed: return [0.2, 0.8, 0.4]
        case .moderate: return [1.0, 0.8, 0.0]
        case .urgent: return [1.0, 0.6, 0.0]
        case .critical: return [0.9, 0.2, 0.2]
        }
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
