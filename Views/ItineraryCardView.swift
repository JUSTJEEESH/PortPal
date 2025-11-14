import SwiftUI

struct ItineraryCardView: View {
    let timer: PortTimer
    @State private var isExpanded = false
    @EnvironmentObject var timerManager: TimerManager
    @State private var showEditSheet = false
    @State private var showDeleteConfirm = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 14) {
                Image(systemName: "ferry.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.blue.opacity(0.15)))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("YOUR CRUISE")
                        .font(.system(size: 10, weight: .semibold, design: .default))
                        .tracking(0.8)
                        .foregroundColor(.secondary)
                    
                    Text(timer.ship)
                        .font(.system(size: 15, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                    
                    Text("7-Day Caribbean • 6,680 guests")
                        .font(.system(size: 11, weight: .regular, design: .default))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray.opacity(0.6))
                        .font(.system(size: 15, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                
                Button(action: { showEditSheet = true }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue.opacity(0.7))
                }
            }
            .padding(18)
            
            if isExpanded {
                Divider()
                    .padding(.horizontal, 18)
                
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(getFullItinerary().enumerated()), id: \.offset) { index, item in
                        if item.type == "port" {
                            FlightyPortStopView(
                                port: item.port,
                                arriveTime: item.arriveTime,
                                departTime: item.departTime,
                                date: item.date,
                                isFirst: item.isFirst,
                                isLast: item.isLast,
                                isCurrent: item.isCurrent
                            )
                        } else if item.type == "atsea" {
                            AtSeaView(days: item.daysAtSea, isCurrent: item.isCurrent)
                        } else if item.type == "overnight" {
                            OvernightView(isCurrent: item.isCurrent)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .contextMenu {
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("Delete Timer", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditTimerSheet(timer: timer, isPresented: $showEditSheet)
        }
        .alert("Delete Timer?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                withAnimation {
                    timerManager.removeTimer(timer.id)
                }
            }
        } message: {
            Text("Are you sure you want to delete this timer? This action cannot be undone.")
        }
    }
    
    private func extractDayNumber(from dayString: String) -> Int {
        // Extract number from "Day X" format
        let components = dayString.components(separatedBy: " ")
        if components.count >= 2, let day = Int(components[1]) {
            return day
        }
        return 0
    }
    
    private func getFullItinerary() -> [(type: String, port: String, arriveTime: String, departTime: String, date: String, daysAtSea: Int, isFirst: Bool, isLast: Bool, isCurrent: Bool)] {
        var result: [(String, String, String, String, String, Int, Bool, Bool, Bool)] = []
        
        var previousDayNumber: Int? = nil
        var processedPorts: Set<String> = []
        
        // Calculate embark date from the timer
        var embarkDate = timer.departure
        for stop in timer.itinerary {
            if stop.status == "Embarkation" {
                let dayNum = extractDayNumber(from: stop.date)
                let timerDayNum = extractDayNumber(from: timer.itinerary.first { $0.port == timer.port && $0.status == "Departure" }?.date ?? "Day 0")
                let dayDiff = timerDayNum - dayNum
                
                if let calcEmbark = Calendar.current.date(byAdding: .day, value: -dayDiff, to: timer.departure) {
                    embarkDate = calcEmbark
                }
                break
            }
        }
        
        let now = Date()
        
        for (index, stop) in timer.itinerary.enumerated() {
            let currentDay = extractDayNumber(from: stop.date)
            let stopDate = calculateStopDate(stop: stop, baseDate: embarkDate)
            
            if stop.status == "Embarkation" {
                result.append(("port", stop.port, "", stop.time, stop.date, 0, true, false, false))
                previousDayNumber = currentDay
                processedPorts.insert(stop.port + stop.date)
                
            } else if stop.status == "Arrival" || stop.status == "Current" {
                // Calculate days at sea
                if let prevDay = previousDayNumber {
                    let daysAtSea = currentDay - prevDay
                    
                    // Check if we're currently "at sea" between the previous port and this one
                    let prevPortDeparted = checkIfDepartedPreviousPort(currentIndex: index, now: now, baseDate: embarkDate)
                    let notYetArrived = now < stopDate
                    let isAtSeaBetween = prevPortDeparted && notYetArrived
                    
                    if daysAtSea > 1 {
                        result.append(("atsea", "", "", "", "", daysAtSea - 1, false, false, isAtSeaBetween))
                    } else if daysAtSea == 1 {
                        result.append(("overnight", "", "", "", "", 0, false, false, isAtSeaBetween))
                    }
                }
                
                // Find matching departure
                var departTime = ""
                var departureDate: Date?
                if index + 1 < timer.itinerary.count {
                    let nextStop = timer.itinerary[index + 1]
                    if nextStop.port == stop.port && nextStop.status == "Departure" {
                        departTime = nextStop.time
                        departureDate = calculateStopDate(stop: nextStop, baseDate: embarkDate)
                    }
                }
                
                let portKey = stop.port + stop.date
                if !processedPorts.contains(portKey) {
                    // Determine if this is the current port
                    let arrivalDate = stopDate
                    let isCurrent: Bool
                    
                    if let depDate = departureDate {
                        // We're at this port if NOW is between arrival and departure
                        isCurrent = now >= arrivalDate && now < depDate
                    } else {
                        isCurrent = (stop.status == "Current")
                    }
                    
                    result.append(("port", stop.port, stop.time, departTime, stop.date, 0, false, false, isCurrent))
                    processedPorts.insert(portKey)
                }
                
                previousDayNumber = currentDay
                
            } else if stop.status == "Return" {
                // Calculate days at sea before return
                if let prevDay = previousDayNumber {
                    let daysAtSea = currentDay - prevDay
                    
                    let prevPortDeparted = checkIfDepartedPreviousPort(currentIndex: index, now: now, baseDate: embarkDate)
                    let notYetArrived = now < stopDate
                    let isAtSeaBetween = prevPortDeparted && notYetArrived
                    
                    if daysAtSea > 1 {
                        result.append(("atsea", "", "", "", "", daysAtSea - 1, false, false, isAtSeaBetween))
                    } else if daysAtSea == 1 {
                        result.append(("overnight", "", "", "", "", 0, false, false, isAtSeaBetween))
                    }
                }
                
                result.append(("port", stop.port, stop.time, "", stop.date, 0, false, true, false))
            }
        }
        
        return result
    }
    
    private func checkIfDepartedPreviousPort(currentIndex: Int, now: Date, baseDate: Date) -> Bool {
        // Look backwards to find the previous departure
        for i in stride(from: currentIndex - 1, through: 0, by: -1) {
            let prevStop = timer.itinerary[i]
            if prevStop.status == "Departure" || prevStop.status == "Embarkation" {
                let prevDepartureDate = calculateStopDate(stop: prevStop, baseDate: baseDate)
                return now >= prevDepartureDate
            }
        }
        return false
    }
    
    private func calculateStopDate(stop: PortStop, baseDate: Date) -> Date {
        let dayNumber = extractDayNumber(from: stop.date)
        let timeComponents = stop.time.split(separator: ":").compactMap { Int($0) }
        let hour = timeComponents.count > 0 ? timeComponents[0] : 0
        let minute = timeComponents.count > 1 ? timeComponents[1] : 0
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: baseDate)
        dateComponents.day! += dayNumber
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        return Calendar.current.date(from: dateComponents) ?? baseDate
    }
}

// MARK: - Flighty-Style Port Stop View (Full Width Layout)
struct FlightyPortStopView: View {
    let port: String
    let arriveTime: String
    let departTime: String
    let date: String
    let isFirst: Bool
    let isLast: Bool
    let isCurrent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Port name - full width
            Text(port.uppercased())
                .font(.system(size: 22, weight: .bold, design: .default))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Times row - full width with left/right alignment
            HStack(spacing: 0) {
                if !isFirst && !isLast {
                    // Left: Arrival
                    VStack(alignment: .leading, spacing: 2) {
                        Text(arriveTime)
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundColor(Color.green.opacity(0.8))
                        Text("Arrive")
                            .font(.system(size: 10, weight: .regular, design: .default))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Center: Ferry with dots (3 per side)
                    HStack(spacing: 3) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 3, height: 3)
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 3, height: 3)
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 3, height: 3)
                        Image(systemName: "ferry.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 3, height: 3)
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 3, height: 3)
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 3, height: 3)
                    }
                    
                    Spacer()
                    
                    // Right: Departure
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(departTime)
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundColor(Color.purple.opacity(0.8))
                        Text("Depart")
                            .font(.system(size: 10, weight: .regular, design: .default))
                            .foregroundColor(.secondary)
                    }
                    
                } else if isFirst {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(departTime)
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundColor(Color.purple.opacity(0.8))
                        Text("Embark")
                            .font(.system(size: 10, weight: .regular, design: .default))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else if isLast {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(arriveTime)
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundColor(Color.green.opacity(0.8))
                        Text("Return")
                            .font(.system(size: 10, weight: .regular, design: .default))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
            
            // Date
            Text(date)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Bottom row - All aboard time
            if !isFirst && !isLast && !departTime.isEmpty {
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(Color.orange.opacity(0.8))
                    
                    Text("All Aboard: \(getAllAboardTime(from: departTime))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "figure.walk")
                            .font(.caption)
                        Text("30 min to pier")
                            .font(.caption)
                    }
                    .foregroundColor(Color.yellow.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.yellow.opacity(0.2))
                    )
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isCurrent ? Color.blue.opacity(0.08) : Color.gray.opacity(0.04))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isCurrent ? Color.blue.opacity(0.3) : Color.clear,
                    lineWidth: 1.5
                )
        )
        .padding(.vertical, 4)
    }
    
    private func getAllAboardTime(from departTime: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        // Try 24-hour format first
        if let time = formatter.date(from: departTime) {
            let allAboard = time.addingTimeInterval(-2700) // 45 minutes before
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: allAboard)
        }
        
        // Try 12-hour format
        formatter.dateFormat = "h:mm a"
        if let time = formatter.date(from: departTime) {
            let allAboard = time.addingTimeInterval(-2700) // 45 minutes before
            return formatter.string(from: allAboard)
        }
        
        return departTime
    }
}

// MARK: - At Sea View (Multiple Days)
struct AtSeaView: View {
    let days: Int
    let isCurrent: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            // Left dashed line
            DashedLine()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                .foregroundColor(Color.gray.opacity(0.4))
                .frame(height: 1)
            
            // Text with anchors
            HStack(spacing: 4) {
                Text("⚓︎")
                    .font(.system(size: 12))
                Text("\(days) \(days == 1 ? "day" : "days") at sea")
                    .font(.system(size: 10, weight: .semibold, design: .default))
                    .tracking(0.3)
                Text("⚓︎")
                    .font(.system(size: 12))
            }
            .foregroundColor(isCurrent ? .blue : .secondary)
            .padding(.horizontal, 8)
            .fixedSize()
            
            // Right dashed line
            DashedLine()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                .foregroundColor(Color.gray.opacity(0.4))
                .frame(height: 1)
        }
        .padding(.vertical, 12)
        .background(isCurrent ? Color.blue.opacity(0.08) : Color.clear)
        .cornerRadius(8)
    }
}

// MARK: - Overnight View (One Night at Sea)
struct OvernightView: View {
    let isCurrent: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            // Left dashed line
            DashedLine()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                .foregroundColor(Color.gray.opacity(0.4))
                .frame(height: 1)
            
            // Moon with text
            HStack(spacing: 4) {
                Image(systemName: "moon.fill")
                    .font(.system(size: 10))
                    .foregroundColor(isCurrent ? .blue : .secondary)
                Text("Overnight at sea")
                    .font(.system(size: 10, weight: .semibold, design: .default))
                    .tracking(0.3)
                    .foregroundColor(isCurrent ? .blue : .secondary)
            }
            .padding(.horizontal, 8)
            .fixedSize()
            
            // Right dashed line
            DashedLine()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                .foregroundColor(Color.gray.opacity(0.4))
                .frame(height: 1)
        }
        .padding(.vertical, 12)
        .background(isCurrent ? Color.blue.opacity(0.08) : Color.clear)
        .cornerRadius(8)
    }
}

// Helper shape for dashed line
struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
