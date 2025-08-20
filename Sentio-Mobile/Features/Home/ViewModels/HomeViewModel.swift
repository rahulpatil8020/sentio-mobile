
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    static let shared = HomeViewModel()
    private init() {}

    func loadTodayIfNeeded() async {
        let appState = AppState.shared
        guard appState.today == nil else {
            print("Today’s data already loaded")
            appState.isHomeLoading = false // ✅ Also stop loading if already loaded
            return
        }

        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            let dateString = formatter.string(from: appState.selectedDate)
            let endpoint = "/daily-data/today?day=\(dateString)"

            let fullResponse: DailyDataFullResponse = try await APIClient.shared.request(
                endpoint: endpoint,
                requiresAuth: true
            )

            appState.habits = fullResponse.habits
            appState.today = DailyDataResponse(
                todos: fullResponse.todos,
                upcomingReminders: fullResponse.upcomingReminders,
                emotionalStates: fullResponse.emotionalStates,
                transcripts: fullResponse.transcripts
            )
            appState.isHomeLoading = false // ✅ Stop loading

        } catch {
            print("Failed to load today’s data: \(error.localizedDescription)")
            appState.isHomeLoading = false // ✅ Stop loading even on failure

        }
    }
}
// Helper struct for full response including habits
struct DailyDataFullResponse: Decodable {
    let habits: [Habit]
    let todos: [Todo]
    let upcomingReminders: [Reminder]
    let emotionalStates: [EmotionalState]
    let transcripts: [Transcript]
}
