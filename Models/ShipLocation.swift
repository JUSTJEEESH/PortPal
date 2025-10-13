import Foundation
import CoreLocation

struct ShipLocation: Codable {
    let mmsi: String
    let latitude: Double
    let longitude: Double
    let speed: Double
    let course: Double
    let heading: Double
    let timestamp: Date
    let status: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct ETACalculation {
    let estimatedArrival: Date
    let status: ArrivalStatus
    let minutesEarly: Int?
    let minutesLate: Int?
    
    enum ArrivalStatus {
        case onSchedule
        case early
        case delayed
    }
}

// Helper extension for distance calculation
extension CLLocationCoordinate2D {
    func distance(to coordinate: CLLocationCoordinate2D) -> Double {
        let from = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let to = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distanceMeters = from.distance(from: to)
        return distanceMeters / 1852.0 // Convert to nautical miles
    }
}
