import Foundation

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()
    private init() {
        self.isHomeLoading = true
        self.isLoggedIn = TokenManager.shared.accessToken != nil
        self.selectedDate = Calendar.current.startOfDay(for: Date())
        self.isHomeLoadingFirstTime = true
        // Mock/demo defaults (optional)
        self.today = DailyDataResponse.mock
        self.habits = Habit.mockList
        self.lastJournalSnippet = today?.transcripts.first?.text

        if isLoggedIn {
            self.currentUser = UserManager.shared.loadUser()
            Task { await UserService.shared.refreshUser() }
        }
    }

    @Published var isLoggedIn: Bool
    @Published var currentUser: User?
    @Published var selectedDate: Date
    @Published var lastJournalSnippet: String?
    @Published var isProcessingTranscript: Bool = false
    @Published var isHomeLoading: Bool
    @Published var isHomeLoadingFirstTime: Bool

    // Long-lived data
    @Published var habits: [Habit] = []                // Fetched with "today" once
    @Published var today: DailyDataResponse?           // Today's “incomplete todos + reminders + emotions + transcripts”

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
