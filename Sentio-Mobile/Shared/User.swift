import Foundation

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let createdAt: String
    let isOnboarded: Bool
    let city: String?
    let country: String?
    let profession: String?
    let goals: [String]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, email, createdAt, isOnboarded, city, country, profession, goals
    }
}
