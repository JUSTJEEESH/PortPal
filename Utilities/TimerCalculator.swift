import Foundation

struct TimerCalculator {
    static func calculateTimeLeft(from departure: Date) -> (hours: Int, minutes: Int, seconds: Int) {
        let now = Date()
        let diff = departure.timeIntervalSince(now)
        
        guard diff > 0 else {
            return (0, 0, 0)
        }
        
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        let seconds = Int(diff) % 60
        
        return (hours, minutes, seconds)
    }
    
    static func calculateProgress(from departure: Date) -> Double {
        let now = Date()
        let totalTime = departure.timeIntervalSince(now)
        let maxTime: TimeInterval = 24 * 3600
        
        return max(0, min(1, totalTime / maxTime))
    }
}
