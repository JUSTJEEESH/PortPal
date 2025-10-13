import SwiftUI

struct WeatherCardView: View {
    let timer: PortTimer
    @AppStorage("temperatureUnit") var temperatureUnit = "fahrenheit"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("WEATHER")
                        .font(.system(size: 11, weight: .semibold, design: .default))
                        .tracking(0.8)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(temperatureUnit == "fahrenheit" ? timer.weather.temp * 9/5 + 32 : timer.weather.temp)")
                            .font(.system(size: 48, weight: .light, design: .default))
                            .foregroundColor(.primary)
                        
                        Text(temperatureUnit == "fahrenheit" ? "°F" : "°C")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(.secondary)
                    }
                    
                    Text(timer.weather.condition)
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(timer.weather.icon)
                    .font(.system(size: 56))
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("3-HOUR FORECAST")
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .tracking(0.8)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    ForEach(timer.weather.forecast.prefix(2), id: \.time) { forecast in
                        VStack(spacing: 10) {
                            Text(forecast.time)
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .foregroundColor(.secondary)
                            
                            Text(forecast.condition == "Clear" ? "☀️" : "⛅")
                                .font(.system(size: 28))
                            
                            Text("\(temperatureUnit == "fahrenheit" ? forecast.temp * 9/5 + 32 : forecast.temp)°")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .glassEffect(cornerRadius: 14, opacity: 0.1)
                    }
                }
            }
        }
        .padding(20)
        .glassEffect(cornerRadius: 24, opacity: 0.12)
    }
}
