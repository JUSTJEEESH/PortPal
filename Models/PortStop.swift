import Foundation

struct PortStop: Identifiable {
    let id: UUID = UUID()
    let port: String
    let date: String
    let time: String
    let status: String
}
