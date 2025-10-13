import SwiftUI
import Combine

@MainActor
final class TimerManager: ObservableObject {
    @Published var timers: [PortTimer] = []
    
    init() {
        // Don't load sample data - let user create their own
    }
    
    func addTimer(_ timer: PortTimer) {
        timers.append(timer)
    }
    
    func removeTimer(_ id: UUID) {
        timers.removeAll { $0.id == id }
    }
    
    func updateTimer(_ updatedTimer: PortTimer) {
        if let index = timers.firstIndex(where: { $0.id == updatedTimer.id }) {
            timers[index] = updatedTimer
        }
    }
}
