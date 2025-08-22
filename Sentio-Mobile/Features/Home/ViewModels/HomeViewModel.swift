import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    static let shared = HomeViewModel()
    private init() {}

    @Published var visible: DayDisplay? = nil

    private var pastCache: [String: PastDayResponse] = [:]
    private var currentTask: Task<Void, Never>?

    private lazy var dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = .current
        f.locale = .current
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    // MARK: - Public

    func loadTodayIfNeeded() async {
        let appState = AppState.shared
        if appState.today != nil, !appState.habits.isEmpty {
            appState.isHomeLoadingFirstTime = false
            if visible == nil, let today = appState.today {
                visible = mapTodayToDisplay(today)
            }
            return
        }
        await load(for: Date())
    }

    func load(for date: Date, force: Bool = false) async {
        let appState = AppState.shared
        let key = dayFormatter.string(from: date)
        let isToday = Calendar.current.isDateInToday(date)

        currentTask?.cancel()

        // ✅ Differentiate first-time load vs normal load
        if isToday, appState.isHomeLoadingFirstTime {
            appState.isHomeLoadingFirstTime = true
        } else {
            appState.isHomeLoading = true
        }

        currentTask = Task { [weak self] in
            guard let self else { return }

            do {
                if isToday {
                    let resp: DailyDataFullResponse = try await self.fetchToday(forKey: key)
                    appState.habits = resp.habits
                    appState.today = DailyDataResponse(
                        todos: resp.todos,
                        upcomingReminders: resp.upcomingReminders,
                        emotionalStates: resp.emotionalStates,
                        transcripts: resp.transcripts
                    )
                    self.visible = self.mapTodayToDisplay(appState.today!)
                    
                    // ✅ Once today is successfully loaded first time
                    appState.isHomeLoadingFirstTime = false
                } else {
                    if !force, let cached = pastCache[key] {
                        self.visible = self.mapPastToDisplay(cached)
                    } else {
                        let resp: PastDayResponse = try await self.fetchPast(forKey: key)
                        pastCache[key] = resp
                        self.visible = self.mapPastToDisplay(resp)
                    }
                }

                appState.isHomeLoading = false
            } catch {
                if Task.isCancelled { return }
                print("Load error \(key): \(error.localizedDescription)")
                appState.isHomeLoading = false
                appState.isHomeLoadingFirstTime = false
            }
        }

        await currentTask?.value
    }

    func refresh(for date: Date) async {
        await load(for: date, force: true)
    }
    // MARK: - Private networking

    private func fetchToday(forKey dayKey: String) async throws -> DailyDataFullResponse {
        let endpoint = "/daily-data/today?day=\(dayKey)"
        return try await APIClient.shared.request(endpoint: endpoint, requiresAuth: true)
    }

    private func fetchPast(forKey dayKey: String) async throws -> PastDayResponse {
        let endpoint = "/daily-data/past?day=\(dayKey)"
        return try await APIClient.shared.request(endpoint: endpoint, requiresAuth: true)
    }

    // MARK: - Mappers

    private func mapTodayToDisplay(_ today: DailyDataResponse) -> DayDisplay {
        DayDisplay(
            isToday: true,
            todos: today.todos,
            reminders: today.upcomingReminders,
            emotionalStates: today.emotionalStates,
            transcripts: today.transcripts
        )
    }

    private func mapPastToDisplay(_ past: PastDayResponse) -> DayDisplay {
        DayDisplay(
            isToday: false,
            todos: past.completedTodos,      // ← completed for past days
            reminders: [],                   // no reminders on past
            emotionalStates: past.emotionalStates,
            transcripts: past.transcripts
        )
    }
}
