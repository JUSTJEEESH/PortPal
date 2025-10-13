import Foundation

struct WeatherData {
    let temp: Int
    let condition: String
    let icon: String
    let forecast: [ForecastHour]
}

struct ForecastHour {
    let time: String
    let temp: Int
    let condition: String
}
