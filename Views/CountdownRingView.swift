import SwiftUI
import Combine

struct CountdownRingView: View {
    let timer: PortTimer
    @AppStorage("useRealShipData") var useRealShipData = false
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
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.5), value: currentStateColor)
                    .animation(.linear(duration: 1), value: calculateProgress())
                    .accessibilityHidden(true) // Hide decorative ring from VoiceOver
                
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
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityTimerLabel)
            .accessibilityValue(accessibilityTimerValue)
            .accessibilityHint("Countdown timer for ship departure")

            VStack(spacing: 8) {
                Text(currentDestination)
                    .font(.system(size: 22, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                    .accessibilityLabel("Destination: \(currentDestination)")

                Text(currentBerth)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Berth information: \(currentBerth)")

                HStack(spacing: 6) {
                    Circle()
                        .fill(currentStateColor)
                        .frame(width: 8, height: 8)
                        .accessibilityHidden(true)

                    Text(currentStatusText)
                        .font(.system(size: 13, weight: .semibold, design: .default))
                        .foregroundColor(currentStateColor)
                }
                .padding(.top, 4)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Status: \(currentStatusText)")
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            updateTimer()
        }
        .onAppear {
            stateManager.useRealShipData = useRealShipData
            stateManager.isTestMode = !useRealShipData
            stateManager.startMonitoring(for: timer)
            updateTimer()
        }
        .onDisappear {
            stateManager.stopMonitoring()
        }
        .onChange(of: useRealShipData) {
            stateManager.useRealShipData = useRealShipData
            stateManager.isTestMode = !useRealShipData
            stateManager.stopMonitoring()
            stateManager.startMonitoring(for: timer)
        }
    }
    
    // MARK: - Computed Properties
    private var currentStateColor: Color {
        if stateManager.currentState == .explorationTime {
            return explorationUrgencyColor
        }

        // Use the new PortPal color palette
        return stateManager.currentState.colorTheme.color
    }

    private var explorationUrgencyColor: Color {
        // Use the new PortPal urgency colors
        return stateManager.explorationUrgency.color
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
        let totalSeconds = Int(targetDate.timeIntervalSince(Date()))
        
        // Ensure we don't show negative time
        guard totalSeconds > 0 else {
            displayDays = 0
            displayHours = 0
            displayMinutes = 0
            displaySeconds = 0
            displayFormat = "urgent"
            return
        }
        
        // Calculate days, hours, minutes, seconds
        let days = totalSeconds / 86400
        let remainingAfterDays = totalSeconds % 86400
        let hours = remainingAfterDays / 3600
        let remainingAfterHours = remainingAfterDays % 3600
        let minutes = remainingAfterHours / 60
        let seconds = remainingAfterHours % 60
        
        displayDays = days
        displayHours = hours
        displayMinutes = minutes
        displaySeconds = seconds
        
        // Determine display format based on time remaining
        let totalMinutes = (days * 24 * 60) + (hours * 60) + minutes
        
        if totalMinutes <= 1 {
            displayFormat = "urgent"
        } else if days > 0 {
            displayFormat = "days"
        } else if hours > 0 {
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
            if stop.status == "Arrival" || stop.status == "Current" {
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

    // MARK: - Accessibility

    private var accessibilityTimerLabel: String {
        "\(stateManager.currentState.displayName) countdown"
    }

    private var accessibilityTimerValue: String {
        if displayFormat == "urgent" {
            return "Depart now! Ship is leaving!"
        } else if displayFormat == "days" {
            return "\(displayDays) days and \(displayHours) hours until departure"
        } else if displayFormat == "hours" {
            return "\(displayHours) hours and \(displayMinutes) minutes until departure"
        } else {
            return "\(displayMinutes) minutes and \(displaySeconds) seconds until departure"
        }
    }
}
