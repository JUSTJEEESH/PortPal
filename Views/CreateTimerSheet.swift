import SwiftUI

struct CreateTimerSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var timerManager: TimerManager
    @Binding var isPresented: Bool
    
    @State private var selectedCruiseLineId: String?
    @State private var selectedShipId: String?
    @State private var selectedItineraryId: String?
    @State private var selectedEmbarkDate = Date()
    @State private var isOngoingCruise = false
    @State private var selectedCurrentPort: String?
    
    var selectedCruiseLine: CruiseLine? {
        CruiseDatabase.getCruiseLines().first { $0.id == selectedCruiseLineId }
    }
    
    var selectedShip: Ship? {
        selectedCruiseLine?.ships.first { $0.id == selectedShipId }
    }
    
    var selectedItinerary: Itinerary? {
        selectedShip?.itineraries.first { $0.id == selectedItineraryId }
    }
    
    var availablePorts: [String] {
        guard let itinerary = selectedItinerary else { return [] }
        return itinerary.stops
            .filter { $0.status == "Arrival" || $0.status == "Departure" }
            .map { $0.port }
            .uniqued()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedOceanGradient()
                
                Form {
                    Section(header: Text("Cruise Line")) {
                        Picker("Select Cruise Line", selection: $selectedCruiseLineId) {
                            Text("Choose a cruise line").tag(nil as String?)
                            ForEach(CruiseDatabase.getCruiseLines()) { line in
                                Text(line.name).tag(line.id as String?)
                            }
                        }
                    }
                    
                    if let cruiseLine = selectedCruiseLine {
                        Section(header: Text("Ship")) {
                            Picker("Select Ship", selection: $selectedShipId) {
                                Text("Choose a ship").tag(nil as String?)
                                ForEach(cruiseLine.ships) { ship in
                                    Text(ship.name).tag(ship.id as String?)
                                }
                            }
                        }
                    }
                    
                    if let ship = selectedShip {
                        Section(header: Text("Itinerary")) {
                            Picker("Select Itinerary", selection: $selectedItineraryId) {
                                Text("Choose an itinerary").tag(nil as String?)
                                ForEach(ship.itineraries) { itinerary in
                                    Text(itinerary.name).tag(itinerary.id as String?)
                                }
                            }
                        }
                    }
                    
                    if let _ = selectedItinerary {
                        Section(header: Text("Cruise Status")) {
                            Toggle("This cruise is already in progress", isOn: $isOngoingCruise)
                                .onChange(of: isOngoingCruise) {
                                    if !isOngoingCruise {
                                        selectedCurrentPort = nil
                                    }
                                }
                        }
                        
                        if isOngoingCruise {
                            Section(header: Text("Current Location")) {
                                Picker("Where is the ship now?", selection: $selectedCurrentPort) {
                                    Text("Select current port").tag(nil as String?)
                                    ForEach(availablePorts, id: \.self) { port in
                                        Text(port).tag(port as String?)
                                    }
                                }
                            }
                        } else {
                            Section(header: Text("Embarkation Date")) {
                                DatePicker("Date", selection: $selectedEmbarkDate, displayedComponents: [.date])
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: { dismiss() })
                        .font(.system(size: 16, weight: .regular, design: .default))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let itinerary = selectedItinerary, let ship = selectedShip {
                            if isOngoingCruise, let currentPort = selectedCurrentPort {
                                createTimersForOngoingCruise(itinerary, ship: ship, currentPort: currentPort)
                            } else {
                                createTimersForItinerary(itinerary, ship: ship, embarkDate: selectedEmbarkDate)
                            }
                            dismiss()
                        }
                    }
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .disabled(selectedItinerary == nil || (isOngoingCruise && selectedCurrentPort == nil))
                }
            }
        }
    }
    
    private func createTimersForOngoingCruise(_ itinerary: Itinerary, ship: Ship, currentPort: String) {
        let today = Date()
        let calendar = Calendar.current
        
        // Find where the ship currently is in the itinerary
        var currentDayIndex = 0
        for (index, stop) in itinerary.stops.enumerated() {
            if stop.port == currentPort && (stop.status == "Arrival" || stop.status == "Departure") {
                currentDayIndex = index
                break
            }
        }
        
        // Extract day number from the current stop
        let currentStop = itinerary.stops[currentDayIndex]
        let currentDayNumber = extractDayNumber(from: currentStop.date)
        
        // Calculate embarkation date by working backwards
        let calculatedEmbarkDate = calendar.date(byAdding: .day, value: -currentDayNumber, to: today) ?? today
        
        print("🚢 Creating ongoing cruise timer")
        print("   Current port: \(currentPort)")
        print("   Current day: Day \(currentDayNumber)")
        print("   Calculated embark date: \(calculatedEmbarkDate)")
        
        // Mark current port as "Current" in itinerary
        var updatedItinerary = itinerary.stops
        for i in 0..<updatedItinerary.count {
            if updatedItinerary[i].port == currentPort && updatedItinerary[i].status == "Arrival" {
                updatedItinerary[i] = PortStop(
                    port: updatedItinerary[i].port,
                    date: updatedItinerary[i].date,
                    time: updatedItinerary[i].time,
                    status: "Current"
                )
            }
        }
        
        // Create timers for all future departures
        for stop in itinerary.stops {
            if stop.status == "Departure" {
                let dayNumber = extractDayNumber(from: stop.date)
                let stopDate = calendar.date(byAdding: .day, value: dayNumber, to: calculatedEmbarkDate)!
                let departureTime = parseDepartureTime(stop.time, for: stopDate)
                
                // Only create timer if departure is in the future
                if departureTime > today {
                    let timer = PortTimer(
                        id: UUID(),
                        ship: ship.name,
                        mmsi: ship.mmsi,
                        port: stop.port,
                        berth: "Pier TBD",
                        departure: departureTime,
                        embarkationDate: calculatedEmbarkDate,
                        weather: WeatherData(
                            temp: 28,
                            condition: "Clear",
                            icon: "☀️",
                            forecast: [
                                ForecastHour(time: "+1h", temp: 29, condition: "Clear"),
                                ForecastHour(time: "+3h", temp: 27, condition: "Partly Cloudy")
                            ]
                        ),
                        itinerary: updatedItinerary
                    )
                    
                    print("   ✅ Created timer for \(stop.port) departure: \(departureTime)")
                    timerManager.addTimer(timer)
                }
            }
        }
    }
    
    private func createTimersForItinerary(_ itinerary: Itinerary, ship: Ship, embarkDate: Date) {
        let calendar = Calendar.current
        
        // Get intermediate stops (skip embarkation and final return)
        let intermediateStops = itinerary.stops.dropFirst().dropLast()
        
        for stop in intermediateStops {
            if stop.status == "Departure" {
                let dayNumber = extractDayNumber(from: stop.date)
                let stopDate = calendar.date(byAdding: .day, value: dayNumber, to: embarkDate)!
                let departureTime = parseDepartureTime(stop.time, for: stopDate)
                
                let timer = PortTimer(
                    id: UUID(),
                    ship: ship.name,
                    mmsi: ship.mmsi,
                    port: stop.port,
                    berth: "Pier TBD",
                    departure: departureTime,
                    embarkationDate: embarkDate,
                    weather: WeatherData(
                        temp: 28,
                        condition: "Clear",
                        icon: "☀️",
                        forecast: [
                            ForecastHour(time: "+1h", temp: 29, condition: "Clear"),
                            ForecastHour(time: "+3h", temp: 27, condition: "Partly Cloudy")
                        ]
                    ),
                    itinerary: itinerary.stops
                )
                
                timerManager.addTimer(timer)
            }
        }
    }
    
    private func extractDayNumber(from dateString: String) -> Int {
        let components = dateString.components(separatedBy: " ")
        if components.count >= 2, let day = Int(components[1]) {
            return day
        }
        return 0
    }
    
    private func parseDepartureTime(_ timeString: String, for date: Date) -> Date {
        let calendar = Calendar.current
        let timeComponents = timeString.split(separator: ":").compactMap { Int($0) }
        let hour = timeComponents.count > 0 ? timeComponents[0] : 0
        let minute = timeComponents.count > 1 ? timeComponents[1] : 0
        
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    }
}

extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
