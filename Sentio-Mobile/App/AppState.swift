import Foundation

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var isLoggedIn: Bool
    @Published var currentUser: User?
    @Published var selectedDate: Date
    @Published var lastJournalSnippet: String?
    @Published var isProcessingTranscript: Bool = false
    @Published var isHomeLoading: Bool

    @Published var habits: [Habit] = []
    @Published var today: DailyDataResponse?

    private init() {
        self.isHomeLoading = true
        self.isLoggedIn = TokenManager.shared.accessToken != nil
        self.selectedDate = Calendar.current.startOfDay(for: Date())
        self.today = DailyDataResponse.mock
        self.habits = Habit.mockList
        self.lastJournalSnippet = today?.transcripts.first?.text
        if isLoggedIn {
            self.currentUser = UserManager.shared.loadUser()
            Task {
                await UserService.shared.refreshUser()
            }
            
            // 👇 Set mock data during preview/debug

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
