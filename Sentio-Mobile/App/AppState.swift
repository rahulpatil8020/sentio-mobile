
import Foundation

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var isLoggedIn: Bool
    @Published var currentUser: User?

    private init() {
        self.isLoggedIn = TokenManager.shared.accessToken != nil

        if isLoggedIn {
            self.currentUser = UserManager.shared.loadUser()
            Task {
                await UserService.shared.refreshUser()
            }
        }
    }
    
    func setUser(_ user: User) {
        self.currentUser = user
        UserManager.shared.saveUser(user)
    }

    func logout() {
        TokenManager.shared.clearTokens()
        UserManager.shared.clearUser()
        currentUser = nil
        isLoggedIn = false
    }
}
