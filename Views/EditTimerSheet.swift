import SwiftUI

struct EditTimerSheet: View {
    let timer: PortTimer
    @Binding var isPresented: Bool
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var timerManager: TimerManager
    
    @State private var selectedCruiseLine: String
    @State private var selectedShip: String
    @State private var selectedPort: String
    @State private var selectedBerth: String
    @State private var departureTime: Date
    
    let cruiseLines = ["Royal Caribbean", "Carnival", "Disney Cruise Line", "Norwegian"]
    let ships = ["Symphony of the Seas", "Icon of the Seas", "Harmony of the Seas"]
    let ports = ["Miami", "Port Canaveral", "Galveston", "New York"]
    
    init(timer: PortTimer, isPresented: Binding<Bool>) {
        self.timer = timer
        self._isPresented = isPresented
        
        _selectedCruiseLine = State(initialValue: "Royal Caribbean")
        _selectedShip = State(initialValue: timer.ship)
        _selectedPort = State(initialValue: timer.port)
        _selectedBerth = State(initialValue: timer.berth)
        _departureTime = State(initialValue: timer.departure)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(.systemBackground).opacity(0.95)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Cruise Details")) {
                        Picker("Cruise Line", selection: $selectedCruiseLine) {
                            ForEach(cruiseLines, id: \.self) { line in
                                Text(line).font(.system(size: 16, weight: .regular, design: .default)).tag(line)
                            }
                        }
                        
                        Picker("Ship", selection: $selectedShip) {
                            ForEach(ships, id: \.self) { ship in
                                Text(ship).font(.system(size: 16, weight: .regular, design: .default)).tag(ship)
                            }
                        }
                    }
                    
                    Section(header: Text("Port Information")) {
                        Picker("Departure Port", selection: $selectedPort) {
                            ForEach(ports, id: \.self) { port in
                                Text(port).font(.system(size: 16, weight: .regular, design: .default)).tag(port)
                            }
                        }
                        
                        TextField("Berth", text: $selectedBerth)
                            .font(.system(size: 16, weight: .regular, design: .default))
                    }
                    
                    Section(header: Text("Departure")) {
                        DatePicker("Departure Time", selection: $departureTime, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: { dismiss() })
                        .font(.system(size: 16, weight: .regular, design: .default))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updatedTimer = PortTimer(
                            id: timer.id,
                            ship: selectedShip,
                            mmsi: timer.mmsi,
                            port: selectedPort,
                            berth: selectedBerth,
                            departure: departureTime,
                            embarkationDate: timer.embarkationDate,
                            weather: timer.weather,
                            itinerary: timer.itinerary
                        )
                        
                        timerManager.updateTimer(updatedTimer)
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold, design: .default))
                }
            }
        }
    }
}

