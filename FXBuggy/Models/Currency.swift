import Foundation

struct Currency: Identifiable, Codable, Equatable {
    var id: String { name }
    let code: String
    let name: String
}
