import SwiftUI

struct HomeTab: View {
    @EnvironmentObject var timerManager: TimerManager
    @State private var showSettings = false
    @State private var activeTimerIndex = 0
    @AppStorage("showWeather") var showWeather = true
    @AppStorage("useRealShipData") var useRealShipData = false
    
    var body: some View {
        ZStack {
            // Background layer - bottom most, fullscreen
            AnimatedOceanGradient()
                .edgesIgnoringSafeArea(.all)
            
            // Content layer
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        if timerManager.timers.isEmpty {
                            EmptyStateView()
                        } else if activeTimerIndex < timerManager.timers.count {
                            let timer = timerManager.timers[activeTimerIndex]
                            
                            VStack(spacing: 20) {
                                CountdownRingView(timer: timer)
                                
                                if showWeather {
                                    WeatherCardView(timer: timer)
                                }
                                
                                ItineraryCardView(timer: timer)
                                
                                // "I'm Back on Ship" Button
                                if activeTimerIndex < timerManager.timers.count - 1 {
                                    Button(action: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            activeTimerIndex += 1
                                        }
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20, weight: .semibold))
                                            Text("I'm Back on Ship")
                                                .font(.system(size: 17, weight: .semibold, design: .default))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 0.2, green: 0.8, blue: 0.3),
                                                    Color(red: 0.15, green: 0.7, blue: 0.25)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(14)
                                        .shadow(color: Color.green.opacity(0.4), radius: 12, x: 0, y: 6)
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 100)
                }
            }
            
            // Settings button - floating overlay with liquid glass border
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showSettings.toggle()
                        }
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.6),
                                                Color.white.opacity(0.2),
                                                Color.white.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 12)
                }
                Spacer()
            }
            
            // Settings slide-in panel
            if showSettings {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSettings = false
                        }
                    }
                
                HStack {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Settings")
                                .font(.system(size: 24, weight: .bold, design: .default))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showSettings = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(24)
                        .background(Color(.systemBackground))
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                LiveDataToggle()
                                Divider()
                                TemperatureToggle()
                                Divider()
                                NotificationsSection()
                                Divider()
                                DisplaySection()
                            }
                            .padding(24)
                        }
                        .background(Color(.systemBackground))
                    }
                    .frame(width: 340)
                    .transition(.move(edge: .trailing))
                }
                .ignoresSafeArea()
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Settings Components

struct LiveDataToggle: View {
    @AppStorage("useRealShipData") var useRealShipData = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TRACKING MODE")
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .tracking(1.2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(useRealShipData ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    
                    Text(useRealShipData ? "LIVE" : "TEST")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(useRealShipData ? .green : .orange)
                }
            }
            
            Toggle("Use Real Ship Data (Position API)", isOn: $useRealShipData)
                .font(.system(size: 15, weight: .regular, design: .default))
            
            if useRealShipData {
                HStack(spacing: 8) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                    
                    Text("Live AIS tracking active")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "flask.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    
                    Text("Using simulated data")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
    }
}

struct TemperatureToggle: View {
    @AppStorage("temperatureUnit") var temperatureUnit = "fahrenheit"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TEMPERATURE")
                .font(.system(size: 11, weight: .semibold, design: .default))
                .tracking(1.2)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Button(action: { temperatureUnit = "fahrenheit" }) {
                    Text("°F")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(temperatureUnit == "fahrenheit" ? Color.blue : Color(.systemGray5))
                        .foregroundColor(temperatureUnit == "fahrenheit" ? .white : .primary)
                        .cornerRadius(10)
                }
                
                Button(action: { temperatureUnit = "celsius" }) {
                    Text("°C")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(temperatureUnit == "celsius" ? Color.blue : Color(.systemGray5))
                        .foregroundColor(temperatureUnit == "celsius" ? .white : .primary)
                        .cornerRadius(10)
                }
            }
        }
    }
}

struct NotificationsSection: View {
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var notificationManager: NotificationManager
    @AppStorage("alert60") var alert60 = true
    @AppStorage("alert30") var alert30 = true
    @AppStorage("alert15") var alert15 = true
    @AppStorage("alert5") var alert5 = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("NOTIFICATIONS")
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .tracking(1.2)
                    .foregroundColor(.secondary)

                Spacer()

                // Show authorization status
                if notificationManager.authorizationStatus == .notDetermined {
                    Button("Enable") {
                        Task {
                            _ = await notificationManager.requestAuthorization()
                            await timerManager.rescheduleAllNotifications()
                        }
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.blue)
                } else if notificationManager.authorizationStatus == .denied {
                    Text("Disabled in Settings")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.red)
                }
            }

            VStack(spacing: 8) {
                Toggle("60 min before departure", isOn: $alert60)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .onChange(of: alert60) { _ in
                        Task { await timerManager.rescheduleAllNotifications() }
                    }

                Toggle("30 min before departure", isOn: $alert30)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .onChange(of: alert30) { _ in
                        Task { await timerManager.rescheduleAllNotifications() }
                    }

                Toggle("15 min before departure", isOn: $alert15)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .onChange(of: alert15) { _ in
                        Task { await timerManager.rescheduleAllNotifications() }
                    }

                Toggle("5 min before departure", isOn: $alert5)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .onChange(of: alert5) { _ in
                        Task { await timerManager.rescheduleAllNotifications() }
                    }
            }
        }
        .task {
            // Request authorization on first appearance
            if notificationManager.authorizationStatus == .notDetermined {
                _ = await notificationManager.requestAuthorization()
            }
        }
    }
}

struct DisplaySection: View {
    @AppStorage("showWeather") var showWeather = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DISPLAY")
                .font(.system(size: 11, weight: .semibold, design: .default))
                .tracking(1.2)
                .foregroundColor(.secondary)
            
            Toggle("Show weather forecast", isOn: $showWeather)
                .font(.system(size: 15, weight: .regular, design: .default))
        }
    }
}
