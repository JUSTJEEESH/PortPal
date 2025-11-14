import Foundation

struct WeatherData: Codable {
    let temp: Int
    let condition: String
    let icon: String
    let forecast: [ForecastHour]

    // Default initializer for convenience
    init(temp: Int, condition: String, icon: String, forecast: [ForecastHour] = []) {
        self.temp = temp
        self.condition = condition
        self.icon = icon
        self.forecast = forecast
    }
}

struct ForecastHour: Codable {
    let time: String
    let temp: Int
    let condition: String
}
