import Foundation
import Combine
import CoreLocation

class TimerStateManager: ObservableObject {
    @Published var currentState: TimerState = .settingSailSoon
    @Published var targetDate: Date = Date()
    @Published var explorationUrgency: ExplorationUrgency = .relaxed
    
    private var timer: Timer?
    private let shipTrackingService = ShipTrackingService()
    
    @Published var isTestMode = true
    @Published var simulatedSpeed: Double = 0
    @Published var useRealShipData = false
    @Published var realShipData: ShipLocation? = nil
    
    func startMonitoring(for portTimer: PortTimer) {
        // Start real ship tracking if enabled
        if useRealShipData {
            shipTrackingService.startTracking(
                mmsi: portTimer.ship,
                scheduledArrival: portTimer.departure,
                destinationCoordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
            )
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.updateState(for: portTimer)
        }
        
        updateState(for: portTimer)
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        shipTrackingService.stopTracking()
    }
    
    func updateState(for portTimer: PortTimer) {
        let now = Date()
        
        if isTestMode {
            updateStateForTesting(portTimer: portTimer, currentTime: now)
            return
        }
        
        updateStateWithShipTracking(portTimer: portTimer, currentTime: now)
    }
    
    private func updateStateForTesting(portTimer: PortTimer, currentTime: Date) {
        if currentTime < portTimer.departure {
            currentState = .settingSailSoon
            targetDate = portTimer.departure
            return
        }
        
        for (index, stop) in portTimer.itinerary.enumerated() {
            let stopDate = parseDate(stop.date, time: stop.time, baseDate: portTimer.departure)
            
            if stop.status == "Embarkation" && currentTime < stopDate {
                currentState = .allAboard
                targetDate = stopDate
                return
            }
            
            if stop.status == "Arrival" {
                if currentTime < stopDate {
                    let hoursUntil = stopDate.timeIntervalSince(currentTime) / 3600
                    if hoursUntil < 2 && simulatedSpeed > 0 {
                        currentState = .landHo
                    } else {
                        currentState = .seasTheDay
                    }
                    targetDate = stopDate
                    return
                }
                
                if let nextStop = portTimer.itinerary[safe: index + 1],
                   nextStop.status == "Departure" {
                    let departureDate = parseDate(nextStop.date, time: nextStop.time, baseDate: portTimer.departure)
                    
                    if currentTime < departureDate {
                        currentState = .explorationTime
                        targetDate = departureDate
                        updateExplorationUrgency(timeRemaining: departureDate.timeIntervalSince(currentTime))
                        return
                    }
                }
            }
            
            if stop.status == "Departure" {
                if currentTime < stopDate {
                    currentState = .bonVoyage
                    targetDate = stopDate
                    return
                }
            }
            
            if stop.status == "Return" {
                if currentTime < stopDate {
                    currentState = .untilNextTime
                    targetDate = stopDate
                    return
                } else {
                    currentState = .cruiseComplete
                    targetDate = stopDate
                    return
                }
            }
        }
    }
    
    private func updateStateWithShipTracking(portTimer: PortTimer, currentTime: Date) {
        // Get real ship location from service
        guard let shipLocation = shipTrackingService.currentLocation else {
            // Fallback to test mode if no data
            updateStateForTesting(portTimer: portTimer, currentTime: currentTime)
            return
        }
        
        realShipData = shipLocation
        
        // Use real ship speed to determine state
        let shipSpeed = shipLocation.speed
        
        // If ship is moving (speed > 2 knots), we're at sea
        // If ship is stopped or slow (speed < 2 knots), we're at port
        let isAtSea = shipSpeed > 2.0
        
        // Find where we are in the itinerary based on real position and speed
        for (index, stop) in portTimer.itinerary.enumerated() {
            let stopDate = parseDate(stop.date, time: stop.time, baseDate: portTimer.departure)
            
            // Pre-cruise
            if currentTime < portTimer.departure {
                currentState = .settingSailSoon
                targetDate = portTimer.departure
                return
            }
            
            // Embarkation
            if stop.status == "Embarkation" && currentTime < stopDate {
                currentState = .allAboard
                targetDate = stopDate
                return
            }
            
            // Check if we're approaching or at a port
            if stop.status == "Arrival" {
                let arrivalDate = stopDate
                
                // Are we approaching this port?
                if currentTime < arrivalDate {
                    let hoursUntil = arrivalDate.timeIntervalSince(currentTime) / 3600
                    
                    // If moving and within 2 hours of arrival
                    if isAtSea && hoursUntil < 2 {
                        currentState = .landHo
                        targetDate = arrivalDate
                        return
                    }
                    // If moving and more than 2 hours away
                    else if isAtSea {
                        currentState = .seasTheDay
                        targetDate = arrivalDate
                        return
                    }
                }
                
                // Are we AT this port? (past arrival, not moving much)
                if currentTime >= arrivalDate && !isAtSea {
                    // Find departure time
                    if let nextStop = portTimer.itinerary[safe: index + 1],
                       nextStop.status == "Departure" {
                        let departureDate = parseDate(nextStop.date, time: nextStop.time, baseDate: portTimer.departure)
                        
                        if currentTime < departureDate {
                            currentState = .explorationTime
                            targetDate = departureDate
                            updateExplorationUrgency(timeRemaining: departureDate.timeIntervalSince(currentTime))
                            return
                        }
                    }
                }
            }
            
            // Departing port
            if stop.status == "Departure" {
                let departureDate = stopDate
                
                // Just left port, still near but moving
                if currentTime >= departureDate && currentTime < departureDate.addingTimeInterval(3600) {
                    currentState = .bonVoyage
                    // Find next arrival as target
                    if let nextArrival = findNextArrival(after: index, in: portTimer) {
                        targetDate = nextArrival
                    } else {
                        targetDate = departureDate.addingTimeInterval(3600)
                    }
                    return
                }
            }
            
            // Final return
            if stop.status == "Return" {
                if currentTime < stopDate {
                    currentState = .untilNextTime
                    targetDate = stopDate
                    return
                } else {
                    currentState = .cruiseComplete
                    targetDate = stopDate
                    return
                }
            }
        }
    }
    
    private func findNextArrival(after index: Int, in portTimer: PortTimer) -> Date? {
        for i in (index+1)..<portTimer.itinerary.count {
            let stop = portTimer.itinerary[i]
            if stop.status == "Arrival" {
                return parseDate(stop.date, time: stop.time, baseDate: portTimer.departure)
            }
        }
        return nil
    }
    
    private func updateExplorationUrgency(timeRemaining: TimeInterval) {
        let hours = timeRemaining / 3600
        
        if hours >= 2 {
            explorationUrgency = .relaxed
        } else if hours >= 0.5 {
            explorationUrgency = .moderate
        } else if hours >= 0.25 {
            explorationUrgency = .urgent
        } else {
            explorationUrgency = .critical
        }
    }
    
    func manuallySetState(_ state: TimerState, targetDate: Date) {
        self.currentState = state
        self.targetDate = targetDate
    }
    
    private func parseDate(_ dateString: String, time: String, baseDate: Date) -> Date {
        let components = dateString.components(separatedBy: " ")
        guard components.count >= 2, let dayNumber = Int(components[1]) else {
            return baseDate
        }
        
        let timeComponents = time.split(separator: ":")
        guard timeComponents.count == 2,
              let hour = Int(timeComponents[0]),
              let minute = Int(timeComponents[1]) else {
            return baseDate.addingTimeInterval(Double(dayNumber) * 86400)
        }
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: baseDate)
        dateComponents.day! += dayNumber
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        return Calendar.current.date(from: dateComponents) ?? baseDate
    }
    
    deinit {
        stopMonitoring()
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
