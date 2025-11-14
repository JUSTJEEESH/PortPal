import Foundation
import Combine
import CoreLocation

class TimerStateManager: ObservableObject {
    @Published var currentState: TimerState = .settingSailSoon
    @Published var targetDate: Date = Date()
    @Published var explorationUrgency: ExplorationUrgency = .relaxed
    
    private var timer: Timer?
    
    let shipTrackingService = ShipTrackingService()
    
    @Published var isTestMode = true
    @Published var simulatedSpeed: Double = 0
    @Published var useRealShipData = false
    @Published var realShipData: ShipLocation? = nil
    
    private var currentTimer: PortTimer?
    private var cancellables = Set<AnyCancellable>()
    
    func startMonitoring(for portTimer: PortTimer) {
        currentTimer = portTimer
        
        if useRealShipData {
            print("🚢 Starting real ship tracking for MMSI: \(portTimer.mmsi)")
            print("📍 Ship: \(portTimer.ship)")
            
            let destinationCoordinate = findNextPortCoordinate(for: portTimer)
            
            shipTrackingService.startTracking(
                mmsi: portTimer.mmsi,
                scheduledArrival: portTimer.departure,
                destinationCoordinate: destinationCoordinate
            )
            
            shipTrackingService.$currentLocation
                .sink { [weak self] location in
                    self?.realShipData = location
                }
                .store(in: &cancellables)
        } else {
            print("🧪 Starting in test mode")
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
        cancellables.removeAll()
        print("🛑 Stopped monitoring")
    }
    
    func updateState(for portTimer: PortTimer) {
        let now = Date()
        
        if isTestMode {
            updateStateForTesting(portTimer: portTimer, currentTime: now)
            return
        }
        
        updateStateWithShipTracking(portTimer: portTimer, currentTime: now)
    }
    
    // MARK: - Test Mode State Updates
    
    private func updateStateForTesting(portTimer: PortTimer, currentTime: Date) {
        // Check if there's a "Current" marker (means ship is at this port or just left)
        var currentStatusStop: PortStop?
        var currentIndex = 0
        
        for (index, stop) in portTimer.itinerary.enumerated() {
            if stop.status == "Current" {
                currentStatusStop = stop
                currentIndex = index
                break
            }
        }
        
        let baseEmbarkDate = portTimer.embarkationDate
        let firstStop = portTimer.itinerary.first!
        let firstEmbarkDate = parseDate(firstStop.date, time: firstStop.time, baseDate: baseEmbarkDate)
        
        // Before embarkation
        if currentTime < firstEmbarkDate {
            currentState = .settingSailSoon
            targetDate = firstEmbarkDate
            print("📅 Before cruise - Setting sail soon")
            return
        }
        
        // If ship has "Current" marker at a port, check if it has departed
        if let currentStop = currentStatusStop {
            // Find the departure from this port
            for i in currentIndex..<portTimer.itinerary.count {
                let stop = portTimer.itinerary[i]
                if stop.port == currentStop.port && stop.status == "Departure" {
                    let departureDate = parseDate(stop.date, time: stop.time, baseDate: baseEmbarkDate)
                    
                    // Still at port (before departure)
                    if currentTime < departureDate {
                        currentState = .explorationTime
                        targetDate = departureDate
                        updateExplorationUrgency(timeRemaining: departureDate.timeIntervalSince(currentTime))
                        print("🗺️ Exploration Time at \(currentStop.port) - departure at \(departureDate)")
                        return
                    }
                    
                    // Just departed (within 1 hour of departure)
                    if currentTime < departureDate.addingTimeInterval(3600) {
                        currentState = .bonVoyage
                        // Find next arrival
                        if let nextArrival = findNextArrivalStop(in: portTimer, after: currentTime) {
                            targetDate = nextArrival.date
                            print("👋 Bon Voyage - Just left \(currentStop.port)")
                            return
                        }
                    }
                    
                    // At sea after departure
                    if let nextArrival = findNextArrivalStop(in: portTimer, after: currentTime) {
                        let hoursUntil = nextArrival.date.timeIntervalSince(currentTime) / 3600
                        
                        // Check if it's the final return
                        if nextArrival.port == portTimer.itinerary.last?.port {
                            currentState = .untilNextTime
                            targetDate = nextArrival.date
                            print("🏠 Until Next Time - Heading home to \(nextArrival.port)")
                            return
                        } else if hoursUntil < 2 {
                            currentState = .landHo
                            targetDate = nextArrival.date
                            print("🏝️ Land Ho! Approaching \(nextArrival.port) in \(String(format: "%.1f", hoursUntil)) hours")
                            return
                        } else {
                            currentState = .seasTheDay
                            targetDate = nextArrival.date
                            print("🌊 Seas the Day - Sailing to \(nextArrival.port), ETA in \(String(format: "%.1f", hoursUntil)) hours")
                            return
                        }
                    }
                    break
                }
            }
        }
        
        // No "Current" marker - process chronologically
        for (index, stop) in portTimer.itinerary.enumerated() {
            let stopDate = parseDate(stop.date, time: stop.time, baseDate: baseEmbarkDate)
            
            // Embarkation phase
            if stop.status == "Embarkation" {
                if currentTime < stopDate {
                    currentState = .allAboard
                    targetDate = stopDate
                    print("🎉 All Aboard!")
                    return
                }
                continue
            }
            
            // Arrival at port
            if stop.status == "Arrival" {
                if let nextStop = portTimer.itinerary[safe: index + 1],
                   nextStop.status == "Departure",
                   nextStop.port == stop.port {
                    let arrivalDate = stopDate
                    let departureDate = parseDate(nextStop.date, time: nextStop.time, baseDate: baseEmbarkDate)
                    
                    // Currently docked at this port
                    if currentTime >= arrivalDate && currentTime < departureDate {
                        currentState = .explorationTime
                        targetDate = departureDate
                        updateExplorationUrgency(timeRemaining: departureDate.timeIntervalSince(currentTime))
                        print("🗺️ Exploration Time at \(stop.port) - departure at \(departureDate)")
                        return
                    }
                }
            }
            
            // Departure from port
            if stop.status == "Departure" {
                let departureDate = stopDate
                
                // About to leave (within 1 hour of departure)
                if currentTime < departureDate {
                    let minutesUntil = departureDate.timeIntervalSince(currentTime) / 60
                    if minutesUntil < 60 && minutesUntil > 0 {
                        currentState = .bonVoyage
                        targetDate = departureDate
                        print("👋 Bon Voyage - Departing \(stop.port) soon")
                        return
                    }
                }
            }
            
            // Final return to home port
            if stop.status == "Return" {
                let returnDate = stopDate
                if currentTime < returnDate {
                    currentState = .untilNextTime
                    targetDate = returnDate
                    print("🏠 Until Next Time - Heading home")
                    return
                } else {
                    currentState = .cruiseComplete
                    targetDate = returnDate
                    print("✅ Cruise Complete")
                    return
                }
            }
        }
        
        // Fallback
        currentState = .seasTheDay
        targetDate = currentTime.addingTimeInterval(3600)
        print("⚠️ Fallback state")
    }
    
    private func findNextArrivalStop(in portTimer: PortTimer, after currentTime: Date) -> (port: String, date: Date)? {
        for stop in portTimer.itinerary {
            if stop.status == "Arrival" || stop.status == "Return" {
                let stopDate = parseDate(stop.date, time: stop.time, baseDate: portTimer.embarkationDate)
                if stopDate > currentTime {
                    return (stop.port, stopDate)
                }
            }
        }
        return nil
    }
    
    // MARK: - Live Ship Tracking State Updates
    
    private func updateStateWithShipTracking(portTimer: PortTimer, currentTime: Date) {
        guard let shipLocation = shipTrackingService.currentLocation else {
            print("⚠️ No ship location data available, falling back to test mode")
            updateStateForTesting(portTimer: portTimer, currentTime: currentTime)
            return
        }
        
        realShipData = shipLocation
        let shipSpeed = shipLocation.speed
        let isAtSea = shipSpeed > 2.0
        
        print("📍 Ship at \(String(format: "%.4f", shipLocation.latitude)), \(String(format: "%.4f", shipLocation.longitude))")
        print("⚡ Speed: \(String(format: "%.1f", shipSpeed))kn - \(isAtSea ? "⛴️ AT SEA" : "🏝️ DOCKED")")
        
        let baseEmbarkDate = portTimer.embarkationDate
        let firstStop = portTimer.itinerary.first!
        
        for (index, stop) in portTimer.itinerary.enumerated() {
            let stopDate = parseDate(stop.date, time: stop.time, baseDate: baseEmbarkDate)
            
            let firstEmbarkDate = parseDate(firstStop.date, time: firstStop.time, baseDate: baseEmbarkDate)
            if currentTime < firstEmbarkDate {
                currentState = .settingSailSoon
                targetDate = firstEmbarkDate
                return
            }
            
            if stop.status == "Embarkation" && currentTime < stopDate {
                currentState = .allAboard
                targetDate = stopDate
                return
            }
            
            if stop.status == "Arrival" {
                let arrivalDate = stopDate
                
                if currentTime < arrivalDate {
                    let hoursUntil = arrivalDate.timeIntervalSince(currentTime) / 3600
                    
                    if isAtSea && hoursUntil < 2 {
                        currentState = .landHo
                        targetDate = arrivalDate
                        print("🏝️ LAND HO! Approaching \(stop.port)")
                        return
                    } else if isAtSea {
                        currentState = .seasTheDay
                        targetDate = arrivalDate
                        print("🌊 SEAS THE DAY - Sailing to \(stop.port)")
                        return
                    }
                }
                
                if currentTime >= arrivalDate && !isAtSea {
                    if let nextStop = portTimer.itinerary[safe: index + 1],
                       nextStop.status == "Departure" {
                        let departureDate = parseDate(nextStop.date, time: nextStop.time, baseDate: baseEmbarkDate)
                        
                        if currentTime < departureDate {
                            currentState = .explorationTime
                            targetDate = departureDate
                            updateExplorationUrgency(timeRemaining: departureDate.timeIntervalSince(currentTime))
                            print("🗺️ EXPLORATION TIME at \(stop.port)")
                            return
                        }
                    }
                }
            }
            
            if stop.status == "Departure" {
                let departureDate = stopDate
                
                if currentTime >= departureDate && isAtSea {
                    if let nextArrival = findNextArrival(after: index, in: portTimer, baseDate: baseEmbarkDate) {
                        if currentTime < departureDate.addingTimeInterval(3600) {
                            currentState = .bonVoyage
                            targetDate = nextArrival
                            print("👋 BON VOYAGE - Just left \(stop.port)")
                            return
                        }
                    }
                }
            }
            
            if stop.status == "Return" {
                if currentTime < stopDate {
                    currentState = .untilNextTime
                    targetDate = stopDate
                    print("🏠 UNTIL NEXT TIME - Heading home")
                    return
                } else {
                    currentState = .cruiseComplete
                    targetDate = stopDate
                    print("✅ CRUISE COMPLETE")
                    return
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func findNextArrival(after index: Int, in portTimer: PortTimer, baseDate: Date) -> Date? {
        for i in (index+1)..<portTimer.itinerary.count {
            let stop = portTimer.itinerary[i]
            if stop.status == "Arrival" {
                return parseDate(stop.date, time: stop.time, baseDate: baseDate)
            }
        }
        return nil
    }
    
    private func findNextPortCoordinate(for portTimer: PortTimer) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 25.7617, longitude: -80.1918)
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

// MARK: - Array Extension

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
