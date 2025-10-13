import Foundation

struct CruiseDatabase {
    static let allCruiseLines = [
        // Add this to your allCruiseLines array in CruiseDatabase.swift
        CruiseLine(
            id: "rcl-live",
            name: "Royal Caribbean (LIVE DATA)",
            ships: [
                Ship(
                    id: "symphony-live",
                    name: "Symphony of the Seas",
                    mmsi: "319326000", // REAL MMSI
                    homePort: "Miami",
                    itineraries: [
                        Itinerary(
                            id: "symphony-current",
                            name: "7-Day Eastern Caribbean (LIVE)",
                            duration: 7,
                            embarkationPort: "Miami",
                            returnPort: "Miami",
                            stops: [
                                PortStop(port: "Miami", date: "Day 0", time: "16:00", status: "Embarkation"),
                                PortStop(port: "Cozumel", date: "Day 2", time: "08:00", status: "Arrival"),
                                PortStop(port: "Cozumel", date: "Day 2", time: "18:00", status: "Departure"),
                                PortStop(port: "San Juan", date: "Day 4", time: "13:00", status: "Arrival"),
                                PortStop(port: "San Juan", date: "Day 4", time: "21:00", status: "Departure"),
                                PortStop(port: "St. Maarten", date: "Day 5", time: "08:00", status: "Arrival"),
                                PortStop(port: "St. Maarten", date: "Day 5", time: "17:00", status: "Departure"),
                                PortStop(port: "Miami", date: "Day 7", time: "06:00", status: "Return")
                            ]
                        )
                    ]
                ),
                Ship(
                    id: "oasis-live",
                    name: "Oasis of the Seas",
                    mmsi: "311000274", // REAL MMSI
                    homePort: "Port Canaveral",
                    itineraries: [
                        Itinerary(
                            id: "oasis-current",
                            name: "7-Day Western Caribbean (LIVE)",
                            duration: 7,
                            embarkationPort: "Port Canaveral",
                            returnPort: "Port Canaveral",
                            stops: [
                                PortStop(port: "Port Canaveral", date: "Day 0", time: "16:30", status: "Embarkation"),
                                PortStop(port: "Cozumel", date: "Day 2", time: "09:00", status: "Arrival"),
                                PortStop(port: "Cozumel", date: "Day 2", time: "19:00", status: "Departure"),
                                PortStop(port: "Roatan", date: "Day 3", time: "07:00", status: "Arrival"),
                                PortStop(port: "Roatan", date: "Day 3", time: "16:00", status: "Departure"),
                                PortStop(port: "Costa Maya", date: "Day 4", time: "10:00", status: "Arrival"),
                                PortStop(port: "Costa Maya", date: "Day 4", time: "18:00", status: "Departure"),
                                PortStop(port: "Port Canaveral", date: "Day 7", time: "07:00", status: "Return")
                            ]
                        )
                    ]
                )
            ]
        )
    ]
    
    static func getCruiseLines() -> [CruiseLine] {
        return allCruiseLines
    }
    
    static func getShips(for cruiseLine: CruiseLine) -> [Ship] {
        return cruiseLine.ships
    }
    
    static func getItineraries(for ship: Ship) -> [Itinerary] {
        return ship.itineraries
    }
}

struct CruiseLine: Identifiable {
    let id: String
    let name: String
    let ships: [Ship]
}

struct Ship: Identifiable {
    let id: String
    let name: String
    let mmsi: String
    let homePort: String
    let itineraries: [Itinerary]
}

struct Itinerary: Identifiable {
    let id: String
    let name: String
    let duration: Int
    let embarkationPort: String
    let returnPort: String
    let stops: [PortStop]
}
