import Foundation
import CoreLocation
import Combine

class ShipTrackingService: ObservableObject {
    @Published var currentLocation: ShipLocation?
    @Published var etaCalculation: ETACalculation?
    @Published var isTracking = false
    @Published var lastError: String?
    @Published var lastUpdateTime: Date?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var trackingTimer: Timer?
    private var timeoutTimer: Timer?
    private var hasReceivedData = false

    // AISStream.io API key (loaded from secure Config)
    private let apiKey = Config.aisStreamAPIKey

    private var currentMMSI: String = ""
    
    // Start tracking a ship via WebSocket
    func startTracking(mmsi: String, scheduledArrival: Date, destinationCoordinate: CLLocationCoordinate2D) {
        print("\n🚢 ========================================")
        print("🚢 START TRACKING WITH AISSTREAM.IO")
        print("🚢 MMSI: \(mmsi)")
        print("🚢 ========================================\n")
        
        currentMMSI = mmsi
        isTracking = true
        hasReceivedData = false
        lastError = nil
        
        // Set timeout: if no data received in 30 seconds, use simulated data
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { [weak self] _ in
            guard let self = self, !self.hasReceivedData else { return }
            
            print("⏱️ Timeout: No live data received after 30 seconds")
            print("🔄 Falling back to simulated data for MMSI: \(mmsi)")
            
            Task {
                await self.useSimulatedData(mmsi: mmsi)
            }
        }
        
        // Connect to AISStream.io WebSocket
        connectWebSocket(mmsi: mmsi, destination: destinationCoordinate, scheduledArrival: scheduledArrival)
    }
    
    func stopTracking() {
        isTracking = false
        hasReceivedData = false
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        trackingTimer?.invalidate()
        trackingTimer = nil
        timeoutTimer?.invalidate()
        timeoutTimer = nil
        print("🛑 Stopped ship tracking")
    }
    
    private func connectWebSocket(mmsi: String, destination: CLLocationCoordinate2D, scheduledArrival: Date) {
        guard let url = URL(string: "wss://stream.aisstream.io/v0/stream") else {
            print("❌ Invalid WebSocket URL")
            return
        }
        
        print("📡 Connecting to AISStream.io WebSocket...")
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        // Subscribe to North America + Central America + Caribbean region
        // Covers: Alaska, West Coast, East Coast, Gulf of Mexico, Caribbean, Central America
        let subscriptionMessage: [String: Any] = [
            "Apikey": apiKey,  // Note: lowercase 'k' per documentation
            "BoundingBoxes": [
                [[5.0, -170.0], [72.0, -50.0]]  // North/Central America
            ],
            "FiltersShipMMSI": [mmsi],
            "FilterMessageTypes": ["PositionReport"]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: subscriptionMessage),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📤 Sending subscription: \(jsonString)")
            webSocketTask?.send(.string(jsonString)) { error in
                if let error = error {
                    print("❌ Failed to send subscription: \(error)")
                } else {
                    print("✅ Subscription sent successfully")
                }
            }
        }
        
        // Start receiving messages
        receiveMessage(destination: destination, scheduledArrival: scheduledArrival)
        
        // Heartbeat timer to keep connection alive
        trackingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.webSocketTask?.sendPing { error in
                if let error = error {
                    print("⚠️ Ping failed: \(error)")
                }
            }
        }
    }
    
    private func receiveMessage(destination: CLLocationCoordinate2D, scheduledArrival: Date) {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("📨 Received WebSocket message")
                    self.parseAISMessage(text, destination: destination, scheduledArrival: scheduledArrival)
                    
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        print("📨 Received WebSocket data")
                        self.parseAISMessage(text, destination: destination, scheduledArrival: scheduledArrival)
                    }
                    
                @unknown default:
                    break
                }
                
                // Continue receiving
                self.receiveMessage(destination: destination, scheduledArrival: scheduledArrival)
                
            case .failure(let error):
                print("❌ WebSocket receive error: \(error)")
                print("   Error details: \(error.localizedDescription)")
                Task {
                    await MainActor.run {
                        self.lastError = "WebSocket error: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    private func parseAISMessage(_ jsonString: String, destination: CLLocationCoordinate2D, scheduledArrival: Date) {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let messageData = json["Message"] as? [String: Any],
              let positionReport = messageData["PositionReport"] as? [String: Any] else {
            print("⚠️ Could not parse AIS message")
            return
        }
        
        // Extract AIS data
        guard let latitude = positionReport["Latitude"] as? Double,
              let longitude = positionReport["Longitude"] as? Double else {
            print("⚠️ Missing position data")
            return
        }
        
        let speed = positionReport["Sog"] as? Double ?? 0.0 // Speed over ground
        let course = positionReport["Cog"] as? Double ?? 0.0 // Course over ground
        let heading = positionReport["TrueHeading"] as? Double ?? course
        let navStatus = positionReport["NavigationalStatus"] as? Int ?? 0
        let mmsi = String(messageData["UserID"] as? Int ?? 0)
        
        // CRITICAL: Only process messages from OUR ship
        guard mmsi == self.currentMMSI else {
            // Silently ignore other ships
            return
        }
        
        // Mark that we received data
        self.hasReceivedData = true
        self.timeoutTimer?.invalidate()
        
        print("✅ Parsed AIS Position Report (LIVE DATA):")
        print("   MMSI: \(mmsi)")
        print("   Position: \(latitude), \(longitude)")
        print("   Speed: \(speed) knots")
        print("   Course: \(course)°")
        print("   Nav Status: \(navStatus)")
        
        Task {
            await MainActor.run {
                self.currentLocation = ShipLocation(
                    mmsi: mmsi,
                    latitude: latitude,
                    longitude: longitude,
                    speed: speed,
                    course: course,
                    heading: heading,
                    timestamp: Date(),
                    status: String(navStatus)
                )
                
                self.lastUpdateTime = Date()
                self.lastError = nil // Clear any previous errors since we got live data
                
                print("✅ LIVE Ship location PUBLISHED to UI")
            }
            
            // Calculate ETA
            self.calculateETA(scheduledArrival: scheduledArrival, destination: destination)
        }
    }
    
    // Calculate ETA
    private func calculateETA(scheduledArrival: Date, destination: CLLocationCoordinate2D) {
        guard let location = currentLocation else { return }
        
        let currentPosition = location.coordinate
        let distance = currentPosition.distance(to: destination)
        let speed = location.speed
        
        guard speed > 0.1 else { return }
        
        let hoursToArrival = distance / speed
        let estimatedArrival = Date().addingTimeInterval(hoursToArrival * 3600)
        let difference = estimatedArrival.timeIntervalSince(scheduledArrival) / 60
        
        let status: ETACalculation.ArrivalStatus
        let minutesEarly: Int?
        let minutesLate: Int?
        
        if abs(difference) < 30 {
            status = .onSchedule
            minutesEarly = nil
            minutesLate = nil
        } else if difference < 0 {
            status = .early
            minutesEarly = Int(abs(difference))
            minutesLate = nil
        } else {
            status = .delayed
            minutesEarly = nil
            minutesLate = Int(difference)
        }
        
        etaCalculation = ETACalculation(
            estimatedArrival: estimatedArrival,
            status: status,
            minutesEarly: minutesEarly,
            minutesLate: minutesLate
        )
        
        print("📊 ETA: \(status), Distance: \(String(format: "%.1f", distance))nm")
    }
    
    // Use simulated data when live data is unavailable
        private func useSimulatedData(mmsi: String) async {
            print("🎭 Using simulated AIS data for MMSI: \(mmsi)")
            
            await MainActor.run {
                switch mmsi {
                // TEST SHIP 1: Wonder of the Seas - Currently at CocoCay (Oct 16, Day 3)
                case "311001033":
                    currentLocation = ShipLocation(
                        mmsi: mmsi,
                        latitude: 25.8272,  // CocoCay coordinates
                        longitude: -77.8811,
                        speed: 0.2,  // Docked
                        course: 0.0,
                        heading: 0.0,
                        timestamp: Date(),
                        status: "5"  // Moored
                    )
                    lastError = "Using simulated data (Ship not broadcasting)"
                    print("✅ Simulated: Wonder of the Seas docked at CocoCay")
                    
                // TEST SHIP 2: Utopia of the Seas - Between CocoCay and Port Canaveral (Oct 16, Day 3)
                case "311001278":
                    currentLocation = ShipLocation(
                        mmsi: mmsi,
                        latitude: 27.1,  // Midway between CocoCay (25.8) and Port Canaveral (28.4)
                        longitude: -79.0,
                        speed: 19.5,  // Cruising at full speed
                        course: 340.0,  // Northwest towards Port Canaveral
                        heading: 340.0,
                        timestamp: Date(),
                        status: "0"  // Under way using engine
                    )
                    lastError = "Using simulated data (Ship not broadcasting)"
                    print("✅ Simulated: Utopia of the Seas sailing to Port Canaveral")
                    
                // TEST SHIP 3: Icon of the Seas - Docked in Miami (future departure Nov 15)
                case "311001276":
                    currentLocation = ShipLocation(
                        mmsi: mmsi,
                        latitude: 25.7753,  // Miami Port coordinates
                        longitude: -80.1864,
                        speed: 0.0,  // Docked
                        course: 0.0,
                        heading: 0.0,
                        timestamp: Date(),
                        status: "5"  // Moored
                    )
                    lastError = "Using simulated data (Ship not broadcasting)"
                    print("✅ Simulated: Icon of the Seas docked in Miami - future departure")
                    
                default:
                    lastError = "No data available for MMSI: \(mmsi)"
                    print("❌ Unknown MMSI, no simulation available")
                }
                
                if currentLocation != nil {
                    lastUpdateTime = Date()
                }
            }
        }
    
    deinit {
        stopTracking()
    }
}

// MARK: - Helper extension
extension String {
    var navigationStatusDescription: String {
        switch self {
        case "0": return "Under way using engine"
        case "1": return "At anchor"
        case "2": return "Not under command"
        case "3": return "Restricted manoeuvrability"
        case "4": return "Constrained by draught"
        case "5": return "Moored"
        case "6": return "Aground"
        case "7": return "Engaged in fishing"
        case "8": return "Under way sailing"
        case "15": return "Not defined"
        default: return self
        }
    }
}
