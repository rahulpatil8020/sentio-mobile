
import Foundation

struct User: Decodable, Identifiable {
    let id: String
    let name: String
    let email: String
    let createdAt: String
    let isOnboarded: Bool

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, email, createdAt, isOnboarded
    }
}
