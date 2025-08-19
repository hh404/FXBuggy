import Foundation

struct RatesResponse: Codable, Equatable {
    let base: String
    let timestamp: TimeInterval
    let rates: [String: Double]
}
