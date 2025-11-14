import Foundation

struct PortStop: Identifiable, Codable {
    let id: UUID
    let port: String
    let date: String
    let time: String
    let status: String

    // Default initializer
    init(id: UUID = UUID(), port: String, date: String, time: String, status: String) {
        self.id = id
        self.port = port
        self.date = date
        self.time = time
        self.status = status
    }
}
