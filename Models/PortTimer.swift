import Foundation

struct PortTimer: Identifiable {
    let id: UUID
    let ship: String
    let mmsi: String
    let port: String
    let berth: String
    let departure: Date
    var status: String = "On Schedule"
    let weather: WeatherData
    let itinerary: [PortStop]
}
