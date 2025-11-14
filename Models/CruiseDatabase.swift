import Foundation

struct CruiseDatabase {
    static let allCruiseLines = [
        CruiseLine(
            id: "rcl",
            name: "Royal Caribbean",
            ships: [
                // Caribbean Ships
                Ship(
                    id: "symphony-live",
                    name: "Symphony of the Seas",
                    mmsi: "319326000",
                    homePort: "Miami",
                    itineraries: [
                        Itinerary(
                            id: "symphony-caribbean",
                            name: "7-Day Eastern Caribbean",
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
                    mmsi: "311000274",
                    homePort: "Fort Lauderdale",
                    itineraries: [
                        Itinerary(
                            id: "oasis-caribbean",
                            name: "7-Day Western Caribbean",
                            duration: 7,
                            embarkationPort: "Fort Lauderdale",
                            returnPort: "Fort Lauderdale",
                            stops: [
                                PortStop(port: "Fort Lauderdale", date: "Day 0", time: "16:00", status: "Embarkation"),
                                PortStop(port: "Cozumel", date: "Day 2", time: "07:00", status: "Arrival"),
                                PortStop(port: "Cozumel", date: "Day 2", time: "18:00", status: "Departure"),
                                PortStop(port: "Roatan", date: "Day 3", time: "08:00", status: "Arrival"),
                                PortStop(port: "Roatan", date: "Day 3", time: "17:00", status: "Departure"),
                                PortStop(port: "Costa Maya", date: "Day 4", time: "08:00", status: "Arrival"),
                                PortStop(port: "Costa Maya", date: "Day 4", time: "17:00", status: "Departure"),
                                PortStop(port: "Fort Lauderdale", date: "Day 6", time: "06:00", status: "Return")
                            ]
                        )
                    ]
                ),
                Ship(
                    id: "harmony-live",
                    name: "Harmony of the Seas",
                    mmsi: "311000325",
                    homePort: "Galveston",
                    itineraries: [
                        Itinerary(
                            id: "harmony-western",
                            name: "7-Day Western Caribbean",
                            duration: 7,
                            embarkationPort: "Galveston",
                            returnPort: "Galveston",
                            stops: [
                                PortStop(port: "Galveston", date: "Day 0", time: "16:00", status: "Embarkation"),
                                PortStop(port: "Cozumel", date: "Day 2", time: "08:00", status: "Arrival"),
                                PortStop(port: "Cozumel", date: "Day 2", time: "17:00", status: "Departure"),
                                PortStop(port: "Roatan", date: "Day 3", time: "10:00", status: "Arrival"),
                                PortStop(port: "Roatan", date: "Day 3", time: "18:00", status: "Departure"),
                                PortStop(port: "Costa Maya", date: "Day 4", time: "07:00", status: "Arrival"),
                                PortStop(port: "Costa Maya", date: "Day 4", time: "16:00", status: "Departure"),
                                PortStop(port: "Galveston", date: "Day 7", time: "07:00", status: "Return")
                            ]
                        )
                    ]
                ),
                Ship(
                    id: "allure-live",
                    name: "Allure of the Seas",
                    mmsi: "311000239",
                    homePort: "Port Canaveral",
                    itineraries: [
                        Itinerary(
                            id: "allure-eastern",
                            name: "7-Day Eastern Caribbean",
                            duration: 7,
                            embarkationPort: "Port Canaveral",
                            returnPort: "Port Canaveral",
                            stops: [
                                PortStop(port: "Port Canaveral", date: "Day 0", time: "16:00", status: "Embarkation"),
                                PortStop(port: "Nassau", date: "Day 1", time: "13:00", status: "Arrival"),
                                PortStop(port: "Nassau", date: "Day 1", time: "20:00", status: "Departure"),
                                PortStop(port: "St. Thomas", date: "Day 3", time: "08:00", status: "Arrival"),
                                PortStop(port: "St. Thomas", date: "Day 3", time: "17:00", status: "Departure"),
                                PortStop(port: "St. Maarten", date: "Day 4", time: "08:00", status: "Arrival"),
                                PortStop(port: "St. Maarten", date: "Day 4", time: "17:00", status: "Departure"),
                                PortStop(port: "Port Canaveral", date: "Day 7", time: "06:00", status: "Return")
                            ]
                        )
                    ]
                ),
                // Alaska Ships
                Ship(
                    id: "ovation-alaska",
                    name: "Ovation of the Seas",
                    mmsi: "538005593",
                    homePort: "Seattle",
                    itineraries: [
                        Itinerary(
                            id: "ovation-alaska",
                            name: "7-Day Alaska",
                            duration: 7,
                            embarkationPort: "Seattle",
                            returnPort: "Seattle",
                            stops: [
                                PortStop(port: "Seattle", date: "Day 0", time: "16:00", status: "Embarkation"),
                                PortStop(port: "Juneau", date: "Day 3", time: "13:00", status: "Arrival"),
                                PortStop(port: "Juneau", date: "Day 3", time: "21:00", status: "Departure"),
                                PortStop(port: "Skagway", date: "Day 4", time: "07:00", status: "Arrival"),
                                PortStop(port: "Skagway", date: "Day 4", time: "20:00", status: "Departure"),
                                PortStop(port: "Victoria", date: "Day 6", time: "19:00", status: "Arrival"),
                                PortStop(port: "Victoria", date: "Day 6", time: "23:59", status: "Departure"),
                                PortStop(port: "Seattle", date: "Day 7", time: "06:00", status: "Return")
                            ]
                        )
                    ]
                ),
                // TEST SHIP 1: DEPARTING TODAY (Oct 16)
                Ship(
                    id: "wonder-live",
                    name: "Wonder of the Seas",
                    mmsi: "311001033",
                    homePort: "Port Canaveral",
                    itineraries: [
                        Itinerary(
                            id: "wonder-eastern",
                            name: "7-Day Eastern Caribbean",
                            duration: 7,
                            embarkationPort: "Port Canaveral",
                            returnPort: "Port Canaveral",
                            stops: [
                                PortStop(port: "Port Canaveral", date: "Day 0", time: "16:30", status: "Embarkation"),
                                PortStop(port: "Cozumel", date: "Day 2", time: "08:00", status: "Arrival"),
                                PortStop(port: "Cozumel", date: "Day 2", time: "17:00", status: "Departure"),
                                PortStop(port: "Philipsburg", date: "Day 4", time: "08:00", status: "Arrival"),
                                PortStop(port: "Philipsburg", date: "Day 4", time: "17:00", status: "Departure"),
                                PortStop(port: "Charlotte Amalie", date: "Day 5", time: "08:00", status: "Arrival"),
                                PortStop(port: "Charlotte Amalie", date: "Day 5", time: "17:00", status: "Departure"),
                                PortStop(port: "Port Canaveral", date: "Day 7", time: "06:00", status: "Return")
                            ]
                        )
                    ]
                ),
                // TEST SHIP 2: IN PROGRESS (Currently sailing)
                Ship(
                    id: "utopia-live",
                    name: "Utopia of the Seas",
                    mmsi: "311001278",
                    homePort: "Port Canaveral",
                    itineraries: [
                        Itinerary(
                            id: "utopia-weekend",
                            name: "3-Day Weekend Cruise",
                            duration: 3,
                            embarkationPort: "Port Canaveral",
                            returnPort: "Port Canaveral",
                            stops: [
                                PortStop(port: "Port Canaveral", date: "Day 0", time: "16:00", status: "Embarkation"),
                                PortStop(port: "Nassau", date: "Day 1", time: "13:00", status: "Arrival"),
                                PortStop(port: "Nassau", date: "Day 1", time: "20:00", status: "Departure"),
                                PortStop(port: "CocoCay", date: "Day 2", time: "08:00", status: "Arrival"),
                                PortStop(port: "CocoCay", date: "Day 2", time: "17:00", status: "Departure"),
                                PortStop(port: "Port Canaveral", date: "Day 3", time: "07:00", status: "Return")
                            ]
                        )
                    ]
                ),
                // TEST SHIP 3: FUTURE (Departs Nov 16)
                Ship(
                    id: "icon-future",
                    name: "Icon of the Seas",
                    mmsi: "311001276",
                    homePort: "Miami",
                    itineraries: [
                        Itinerary(
                            id: "icon-caribbean",
                            name: "7-Day Eastern Caribbean",
                            duration: 7,
                            embarkationPort: "Miami",
                            returnPort: "Miami",
                            stops: [
                                PortStop(port: "Miami", date: "Day 0", time: "16:00", status: "Embarkation"),
                                PortStop(port: "CocoCay", date: "Day 1", time: "08:00", status: "Arrival"),
                                PortStop(port: "CocoCay", date: "Day 1", time: "17:00", status: "Departure"),
                                PortStop(port: "Philipsburg", date: "Day 3", time: "08:00", status: "Arrival"),
                                PortStop(port: "Philipsburg", date: "Day 3", time: "17:00", status: "Departure"),
                                PortStop(port: "Basseterre", date: "Day 4", time: "08:00", status: "Arrival"),
                                PortStop(port: "Basseterre", date: "Day 4", time: "17:00", status: "Departure"),
                                PortStop(port: "Miami", date: "Day 7", time: "06:00", status: "Return")
                            ]
                        )
                    ]
                )
            ]
        ),
        CruiseLine(
            id: "carnival",
            name: "Carnival",
            ships: [
                Ship(
                    id: "carnival-celebration",
                    name: "Carnival Celebration",
                    mmsi: "311001470",
                    homePort: "Miami",
                    itineraries: [
                        Itinerary(
                            id: "celebration-eastern",
                            name: "7-Day Eastern Caribbean",
                            duration: 7,
                            embarkationPort: "Miami",
                            returnPort: "Miami",
                            stops: [
                                PortStop(port: "Miami", date: "Day 0", time: "16:00", status: "Embarkation"),
                                PortStop(port: "Grand Turk", date: "Day 2", time: "08:00", status: "Arrival"),
                                PortStop(port: "Grand Turk", date: "Day 2", time: "17:00", status: "Departure"),
                                PortStop(port: "Amber Cove", date: "Day 3", time: "08:00", status: "Arrival"),
                                PortStop(port: "Amber Cove", date: "Day 3", time: "17:00", status: "Departure"),
                                PortStop(port: "St. Thomas", date: "Day 5", time: "08:00", status: "Arrival"),
                                PortStop(port: "St. Thomas", date: "Day 5", time: "17:00", status: "Departure"),
                                PortStop(port: "Miami", date: "Day 7", time: "08:00", status: "Return")
                            ]
                        )
                    ]
                )
            ]
        ),
        CruiseLine(
            id: "norwegian",
            name: "Norwegian Cruise Line",
            ships: [
                Ship(
                    id: "ncl-encore",
                    name: "Norwegian Encore",
                    mmsi: "538008526",
                    homePort: "Seattle",
                    itineraries: [
                        Itinerary(
                            id: "encore-alaska",
                            name: "7-Day Alaska",
                            duration: 7,
                            embarkationPort: "Seattle",
                            returnPort: "Seattle",
                            stops: [
                                PortStop(port: "Seattle", date: "Day 0", time: "16:00", status: "Embarkation"),
                                PortStop(port: "Ketchikan", date: "Day 2", time: "12:00", status: "Arrival"),
                                PortStop(port: "Ketchikan", date: "Day 2", time: "20:00", status: "Departure"),
                                PortStop(port: "Juneau", date: "Day 3", time: "07:00", status: "Arrival"),
                                PortStop(port: "Juneau", date: "Day 3", time: "20:00", status: "Departure"),
                                PortStop(port: "Skagway", date: "Day 4", time: "07:00", status: "Arrival"),
                                PortStop(port: "Skagway", date: "Day 4", time: "15:00", status: "Departure"),
                                PortStop(port: "Seattle", date: "Day 7", time: "06:00", status: "Return")
                            ]
                        )
                    ]
                )
            ]
        ),
        CruiseLine(
            id: "disney",
            name: "Disney Cruise Line",
            ships: [
                Ship(
                    id: "disney-wish",
                    name: "Disney Wish",
                    mmsi: "319241000",
                    homePort: "Port Canaveral",
                    itineraries: [
                        Itinerary(
                            id: "wish-bahamas",
                            name: "3-Day Bahamas",
                            duration: 3,
                            embarkationPort: "Port Canaveral",
                            returnPort: "Port Canaveral",
                            stops: [
                                PortStop(port: "Port Canaveral", date: "Day 0", time: "17:00", status: "Embarkation"),
                                PortStop(port: "Nassau", date: "Day 1", time: "09:30", status: "Arrival"),
                                PortStop(port: "Nassau", date: "Day 1", time: "18:00", status: "Departure"),
                                PortStop(port: "Castaway Cay", date: "Day 2", time: "08:00", status: "Arrival"),
                                PortStop(port: "Castaway Cay", date: "Day 2", time: "16:30", status: "Departure"),
                                PortStop(port: "Port Canaveral", date: "Day 3", time: "07:00", status: "Return")
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
