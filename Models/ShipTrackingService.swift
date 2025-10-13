import Foundation
import CoreLocation
import Combine

class ShipTrackingService: ObservableObject {
    @Published var currentLocation: ShipLocation?
    @Published var etaCalculation: ETACalculation?
    @Published var isTracking = false
    
    private var trackingTimer: Timer?
    private let updateInterval: TimeInterval = 60 // Update every minute
    
    // Start tracking a ship
    func startTracking(mmsi: String, scheduledArrival: Date, destinationCoordinate: CLLocationCoordinate2D) {
        isTracking = true
        
        // Fetch immediately
        Task {
            await fetchShipLocation(mmsi: mmsi)
            calculateETA(scheduledArrival: scheduledArrival, destination: destinationCoordinate)
        }
        
        // Then update periodically
        trackingTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.fetchShipLocation(mmsi: mmsi)
                self?.calculateETA(scheduledArrival: scheduledArrival, destination: destinationCoordinate)
            }
        }
    }
    
    func stopTracking() {
        isTracking = false
        trackingTimer?.invalidate()
        trackingTimer = nil
    }
    
    // Fetch ship location from Position API
    private func fetchShipLocation(mmsi: String) async {
        // Position API endpoint
        guard let url = URL(string: "https://api.vtexplorer.com/vessels/\(mmsi)") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(PositionAPIResponse.self, from: data)
            
            await MainActor.run {
                currentLocation = ShipLocation(
                    mmsi: response.mmsi,
                    latitude: response.latitude,
                    longitude: response.longitude,
                    speed: response.speed,
                    course: response.course,
                    heading: response.heading ?? response.course,
                    timestamp: Date(timeIntervalSince1970: TimeInterval(response.timestamp)),
                    status: response.navigationalStatus ?? "Under way using engine"
                )
            }
            
            print("✅ Ship location updated: \(response.latitude), \(response.longitude) at \(response.speed) knots")
            
        } catch {
            print("❌ Failed to fetch ship location: \(error)")
        }
    }
    
    // Calculate ETA based on current position and speed
    private func calculateETA(scheduledArrival: Date, destination: CLLocationCoordinate2D) {
        guard let location = currentLocation else { return }
        
        let currentPosition = location.coordinate
        let distance = currentPosition.distance(to: destination)
        let speed = location.speed
        
        guard speed > 0 else { return }
        
        // Calculate estimated time to arrival
        let hoursToArrival = distance / speed
        let estimatedArrival = Date().addingTimeInterval(hoursToArrival * 3600)
        
        // Compare with scheduled arrival
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
    }
    
    deinit {
        stopTracking()
    }
}

// MARK: - Position API Response Models
struct PositionAPIResponse: Codable {
    let mmsi: String
    let latitude: Double
    let longitude: Double
    let speed: Double
    let course: Double
    let heading: Double?
    let timestamp: Int
    let navigationalStatus: String?
    let shipName: String?
    let destination: String?
    
    enum CodingKeys: String, CodingKey {
        case mmsi
        case latitude = "lat"
        case longitude = "lon"
        case speed
        case course = "cog"
        case heading = "heading"
        case timestamp
        case navigationalStatus = "navStat"
        case shipName = "name"
        case destination = "destination"
    }
}
