
import Foundation

final class UserManager {
    static let shared = UserManager()
    private init() {}

    private let userKey = "SentioCurrentUser"

    // Save user to UserDefaults
    func saveUser(_ user: User) {
        do {
            let data = try JSONEncoder().encode(user)
            UserDefaults.standard.set(data, forKey: userKey)
        } catch {
            print("❌ Failed to save user: \(error.localizedDescription)")
        }
    }

    // Load user from UserDefaults
    func loadUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userKey) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    // Clear user data
    func clearUser() {
        UserDefaults.standard.removeObject(forKey: userKey)
    }
}
