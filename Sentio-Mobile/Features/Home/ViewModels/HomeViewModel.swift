import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    static let shared = HomeViewModel()
    private init() {}

    // What the UI binds to
    @Published var visible: DayDisplay? = nil

    // Cache past days by "yyyy-MM-dd"
    private var pastCache: [String: PastDayResponse] = [:]

    // Track a cancellable in-flight task for date changes
    private var currentTask: Task<Void, Never>?

    private lazy var dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = .current
        f.locale = .current
        f.timeZone = .current   // local day boundaries
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    // MARK: - Public

    /// Load "today" once on first launch if needed.
    func loadTodayIfNeeded() async {
        let appState = AppState.shared
        if appState.today != nil, !appState.habits.isEmpty {
            appState.isHomeLoading = false
            // Also reflect to `visible` if we haven't yet
            if visible == nil, let today = appState.today {
                visible = mapTodayToDisplay(today)
            }
            return
        }
        await load(for: Date())
    }

    /// Main loader for any selected date. Uses cache for past days.
    func load(for date: Date, force: Bool = false) async {
        let appState = AppState.shared
        let key = dayFormatter.string(from: date)
        let isToday = Calendar.current.isDateInToday(date)

        // Cancel any prior in-flight work
        currentTask?.cancel()

        appState.isHomeLoading = true

        currentTask = Task { [weak self] in
            guard let self else { return }

            do {
                if isToday {
                    // Always load today fresh unless you want to add a today-cache.
                    let resp: DailyDataFullResponse = try await self.fetchToday(forKey: key)
                    // Store long-lived data
                    appState.habits = resp.habits
                    appState.today = DailyDataResponse(
                        todos: resp.todos,
                        upcomingReminders: resp.upcomingReminders,
                        emotionalStates: resp.emotionalStates,
                        transcripts: resp.transcripts
                    )
                    self.visible = self.mapTodayToDisplay(appState.today!)
                } else {
                    // PAST day: serve cache if available and not forcing
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
                // Don't clear visible; keep prior data on screen
            }
        }

        await currentTask?.value
    }

    /// Force refresh currently selected date (ignore cache)
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
