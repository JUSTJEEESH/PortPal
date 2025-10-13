import SwiftUI

struct CreateTimerSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var timerManager: TimerManager
    @Binding var isPresented: Bool
    
    @State private var selectedCruiseLineId: String?
    @State private var selectedShipId: String?
    @State private var selectedItineraryId: String?
    @State private var selectedEmbarkDate = Date()
    
    var selectedCruiseLine: CruiseLine? {
        CruiseDatabase.getCruiseLines().first { $0.id == selectedCruiseLineId }
    }
    
    var selectedShip: Ship? {
        selectedCruiseLine?.ships.first { $0.id == selectedShipId }
    }
    
    var selectedItinerary: Itinerary? {
        selectedShip?.itineraries.first { $0.id == selectedItineraryId }
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
                        Section(header: Text("Embarkation Date")) {
                            DatePicker("Date", selection: $selectedEmbarkDate, displayedComponents: [.date])
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
                            createTimersForItinerary(itinerary, ship: ship, embarkDate: selectedEmbarkDate)
                            dismiss()
                        }
                    }
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .disabled(selectedItinerary == nil)
                }
            }
        }
    }
    
    private func createTimersForItinerary(_ itinerary: Itinerary, ship: Ship, embarkDate: Date) {
        // Get only intermediate ports (skip first embarkation and last return)
        let intermediateStops = itinerary.stops.dropFirst().dropLast()
        
        for stop in intermediateStops {
            // Only create timers for departure times
            if stop.status == "Departure" {
                let calendar = Calendar.current
                let timeComponents = stop.time.split(separator: ":").compactMap { Int($0) }
                let hour = timeComponents.count > 0 ? timeComponents[0] : 0
                let minute = timeComponents.count > 1 ? timeComponents[1] : 0
                
                // Calculate departure date based on day number
                let dayNumber = Int(stop.date.split(separator: " ").last ?? "0") ?? 0
                let departureDate = calendar.date(byAdding: .day, value: dayNumber, to: embarkDate)!
                let finalDepartureTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: departureDate)!
                
                let timer = PortTimer(
                    id: UUID(),
                    ship: ship.name,
                    mmsi: ship.mmsi,
                    port: stop.port,
                    berth: "TBD",
                    departure: finalDepartureTime,
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
}
