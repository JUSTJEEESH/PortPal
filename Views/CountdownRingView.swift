import SwiftUI
import Combine

struct CountdownRingView: View {
    let timer: PortTimer
    @StateObject private var stateManager = TimerStateManager()
    @State private var displayDays = 0
    @State private var displayHours = 0
    @State private var displayMinutes = 0
    @State private var displaySeconds = 0
    @State private var displayFormat = "days"
    
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                
                Circle()
                    .trim(from: 0, to: calculateProgress())
                    .stroke(
                        currentStateColor,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.5), value: currentStateColor)
                    .animation(.linear(duration: 1), value: calculateProgress())
                
                VStack(spacing: 18) {
                    HStack(spacing: 8) {
                        Image(systemName: currentStateIcon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(currentStateColor)
                        
                        Text(stateManager.currentState.displayName.uppercased())
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .tracking(0.8)
                            .foregroundColor(.secondary)
                    }
                    
                    if displayFormat == "urgent" {
                        VStack(spacing: 4) {
                            Text("DEPART NOW!")
                                .font(.system(size: 32, weight: .bold, design: .default))
                                .foregroundColor(.red)
                                .tracking(0.5)
                        }
                    } else if displayFormat == "days" {
                        HStack(alignment: .center, spacing: 8) {
                            VStack(alignment: .center, spacing: 2) {
                                Text("\(displayDays)")
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                    .foregroundColor(.primary)
                                Text("days")
                                    .font(.system(size: 11, weight: .medium, design: .default))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(alignment: .center, spacing: 2) {
                                Text("\(displayHours)")
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                    .foregroundColor(.primary)
                                Text("hrs")
                                    .font(.system(size: 11, weight: .medium, design: .default))
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else if displayFormat == "hours" {
                        HStack(alignment: .center, spacing: 8) {
                            VStack(alignment: .center, spacing: 2) {
                                Text("\(displayHours)")
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                    .foregroundColor(.primary)
                                Text("hrs")
                                    .font(.system(size: 11, weight: .medium, design: .default))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(alignment: .center, spacing: 2) {
                                Text("\(displayMinutes)")
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                    .foregroundColor(.primary)
                                Text("min")
                                    .font(.system(size: 11, weight: .medium, design: .default))
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        HStack(alignment: .center, spacing: 8) {
                            VStack(alignment: .center, spacing: 2) {
                                Text("\(displayMinutes)")
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                    .foregroundColor(.primary)
                                Text("min")
                                    .font(.system(size: 11, weight: .medium, design: .default))
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(alignment: .center, spacing: 2) {
                                Text("\(displaySeconds)")
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                    .foregroundColor(.primary)
                                Text("sec")
                                    .font(.system(size: 11, weight: .medium, design: .default))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if stateManager.currentState == .explorationTime {
                        Text(stateManager.explorationUrgency.message)
                            .font(.system(size: 11, weight: .semibold, design: .default))
                            .foregroundColor(explorationUrgencyColor)
                            .padding(.top, 4)
                    }
                }
            }
            .frame(height: 300)
            .padding(.horizontal, 20)
            
            VStack(spacing: 8) {
                Text(currentDestination)
                    .font(.system(size: 22, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                
                Text(currentBerth)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(currentStateColor)
                        .frame(width: 8, height: 8)
                    
                    Text(currentStatusText)
                        .font(.system(size: 13, weight: .semibold, design: .default))
                        .foregroundColor(currentStateColor)
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            if stateManager.isTestMode {
                testControls
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            updateTimer()
        }
        .onAppear {
            stateManager.startMonitoring(for: timer)
            updateTimer()
        }
        .onDisappear {
            stateManager.stopMonitoring()
        }
    }
    
    // MARK: - Test Controls
    private var testControls: some View {
        VStack(spacing: 16) {
            Divider()
            
            HStack {
                Text("🧪 TEST MODE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.red)
                
                Spacer()
                
                Toggle("Use Real Ship Data", isOn: $stateManager.useRealShipData)
                    .labelsHidden()
                    .onChange(of: stateManager.useRealShipData) { newValue in
                        stateManager.isTestMode = !newValue
                        if newValue {
                            stateManager.startMonitoring(for: timer)
                        }
                    }
            }
            
            if stateManager.useRealShipData {
                // LIVE DATA MODE
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("LIVE DATA ACTIVE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.green)
                        Spacer()
                    }
                    
                    if let shipData = stateManager.realShipData {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current State: \(stateManager.currentState.displayName)")
                                .font(.system(size: 12, weight: .semibold))
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Position")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Text("\(String(format: "%.4f", shipData.latitude))°, \(String(format: "%.4f", shipData.longitude))°")
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Speed")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Text("\(String(format: "%.1f", shipData.speed)) kn")
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundColor(shipData.speed > 2 ? .green : .orange)
                                }
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Heading")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Text("\(Int(shipData.heading))°")
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Status")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Text(shipData.speed > 2 ? "⛴️ Sailing" : "⚓ Docked")
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundColor(shipData.speed > 2 ? .green : .orange)
                                }
                            }
                            
                            Text("Last Update: \(formatTime(shipData.timestamp))")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                    } else {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Fetching ship position...")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                
            } else {
                // TEST MODE WITH SIMULATOR
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current State: \(stateManager.currentState.displayName)")
                        .font(.system(size: 12, weight: .semibold))
                    
                    Text("Target: \(formatTestDate(stateManager.targetDate))")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Ship Speed: \(Int(stateManager.simulatedSpeed)) knots")
                            .font(.system(size: 12, weight: .medium))
                        Spacer()
                        Text(stateManager.simulatedSpeed > 0 ? "⛴️ Moving" : "⚓ Docked")
                            .font(.system(size: 11))
                            .foregroundColor(stateManager.simulatedSpeed > 0 ? .green : .orange)
                    }
                    
                    Slider(value: $stateManager.simulatedSpeed, in: 0...25, step: 1)
                        .accentColor(.blue)
                    
                    HStack(spacing: 8) {
                        Button("Stop") {
                            stateManager.simulatedSpeed = 0
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        
                        Button("Cruise (18kn)") {
                            stateManager.simulatedSpeed = 18
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                        
                        Button("Fast (25kn)") {
                            stateManager.simulatedSpeed = 25
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)
                    }
                    .font(.system(size: 11))
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Jump to State:")
                        .font(.system(size: 12, weight: .medium))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            stateButton(.settingSailSoon, "Pre-Cruise", days: -30)
                            stateButton(.allAboard, "Embark", days: 0, hours: -2)
                            stateButton(.seasTheDay, "At Sea", days: 1)
                            stateButton(.landHo, "Approaching", days: 2, hours: -2)
                            stateButton(.explorationTime, "Exploring", days: 2, hours: 2)
                            stateButton(.bonVoyage, "Departing", days: 2, hours: 7)
                            stateButton(.untilNextTime, "Final Day", days: 6)
                        }
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Actions:")
                        .font(.system(size: 12, weight: .medium))
                    
                    HStack(spacing: 8) {
                        Button("30 Days Before") {
                            jumpToTime(days: -30)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Embark Day") {
                            jumpToTime(days: 0)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Mid-Cruise") {
                            jumpToTime(days: 3)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .font(.system(size: 11))
                }
            }
        }
        .padding()
        .background(Color.red.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss a"
        return formatter.string(from: date)
    }
    
    private func stateButton(_ state: TimerState, _ label: String, days: Int = 0, hours: Int = 0) -> some View {
        Button(label) {
            let targetDate = timer.departure
                .addingTimeInterval(TimeInterval(days * 86400))
                .addingTimeInterval(TimeInterval(hours * 3600))
            stateManager.manuallySetState(state, targetDate: targetDate)
        }
        .buttonStyle(.bordered)
        .tint(stateManager.currentState == state ? .blue : .gray)
        .font(.system(size: 11))
    }
    
    private func jumpToTime(days: Int) {
        stateManager.simulatedSpeed = days < 0 ? 0 : 18
        stateManager.updateState(for: timer)
    }
    
    private func formatTestDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
    
    // MARK: - Computed Properties
    private var currentStateColor: Color {
        if stateManager.currentState == .explorationTime {
            return explorationUrgencyColor
        }
        
        let theme = stateManager.currentState.colorTheme.gradient
        return Color(red: theme[0], green: theme[1], blue: theme[2])
    }
    
    private var explorationUrgencyColor: Color {
        let urgency = stateManager.explorationUrgency.color
        return Color(red: urgency[0], green: urgency[1], blue: urgency[2])
    }
    
    private var currentStateIcon: String {
        switch stateManager.currentState {
        case .settingSailSoon: return "calendar.badge.clock"
        case .allAboard: return "figure.walk.arrival"
        case .seasTheDay: return "water.waves"
        case .landHo: return "location.fill"
        case .explorationTime: return "map.fill"
        case .bonVoyage: return "figure.walk.departure"
        case .untilNextTime: return "flag.checkered"
        case .cruiseComplete: return "checkmark.seal.fill"
        }
    }
    
    private var currentDestination: String {
        switch stateManager.currentState {
        case .settingSailSoon:
            return timer.port
        case .allAboard:
            return "Departing \(timer.port)"
        case .seasTheDay, .landHo:
            return findNextPort() ?? "Next Port"
        case .explorationTime:
            return findCurrentPort() ?? timer.port
        case .bonVoyage:
            return "Leaving \(findCurrentPort() ?? timer.port)"
        case .untilNextTime:
            return timer.port
        case .cruiseComplete:
            return "Journey Complete"
        }
    }
    
    private var currentBerth: String {
        switch stateManager.currentState {
        case .settingSailSoon:
            return "Departing from \(timer.port)"
        case .allAboard:
            return timer.berth
        case .explorationTime:
            return "All Aboard: \(formatAllAboardTime())"
        default:
            return "At Sea"
        }
    }
    
    private var currentStatusText: String {
        switch stateManager.currentState {
        case .settingSailSoon: return "Countdown Active"
        case .allAboard: return "Boarding Now"
        case .seasTheDay: return "Sailing"
        case .landHo: return "Approaching Port"
        case .explorationTime: return "Exploring"
        case .bonVoyage: return "Departing"
        case .untilNextTime: return "Final Leg"
        case .cruiseComplete: return "Completed"
        }
    }
    
    // MARK: - Helper Methods
    private func updateTimer() {
        let targetDate = stateManager.targetDate
        let (h, m, s) = TimerCalculator.calculateTimeLeft(from: targetDate)
        
        let totalSeconds = Int(targetDate.timeIntervalSince(Date()))
        let days = totalSeconds / 86400
        
        displayDays = days
        displayHours = h
        displayMinutes = m
        displaySeconds = s
        
        let totalMinutes = h * 60 + m
        
        if totalMinutes <= 1 {
            displayFormat = "urgent"
        } else if days > 0 {
            displayFormat = "days"
        } else if h > 0 {
            displayFormat = "hours"
        } else {
            displayFormat = "minutes"
        }
    }
    
    private func calculateProgress() -> CGFloat {
        TimerCalculator.calculateProgress(from: stateManager.targetDate)
    }
    
    private func findNextPort() -> String? {
        for stop in timer.itinerary {
            if stop.status == "Arrival" {
                let stopDate = parseDate(stop.date, time: stop.time)
                if stopDate > Date() {
                    return stop.port
                }
            }
        }
        return nil
    }
    
    private func findCurrentPort() -> String? {
        for (index, stop) in timer.itinerary.enumerated() {
            if stop.status == "Arrival" {
                let arrivalDate = parseDate(stop.date, time: stop.time)
                
                if let nextStop = timer.itinerary[safe: index + 1],
                   nextStop.status == "Departure" {
                    let departureDate = parseDate(nextStop.date, time: nextStop.time)
                    
                    if Date() >= arrivalDate && Date() < departureDate {
                        return stop.port
                    }
                }
            }
        }
        return nil
    }
    
    private func formatAllAboardTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: stateManager.targetDate)
    }
    
    private func parseDate(_ dateString: String, time: String) -> Date {
        let components = dateString.components(separatedBy: " ")
        guard components.count >= 2, let dayNumber = Int(components[1]) else {
            return timer.departure
        }
        
        let timeComponents = time.split(separator: ":")
        guard timeComponents.count == 2,
              let hour = Int(timeComponents[0]),
              let minute = Int(timeComponents[1]) else {
            return timer.departure.addingTimeInterval(Double(dayNumber) * 86400)
        }
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: timer.departure)
        dateComponents.day! += dayNumber
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        return Calendar.current.date(from: dateComponents) ?? timer.departure
    }
}
