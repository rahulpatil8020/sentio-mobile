import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    static let shared = HomeViewModel()
    private init() {}

    @Published var visible: DayDisplay? = nil

    private var pastCache: [String: PastDayResponse] = [:]
    private var currentTask: Task<Void, Never>?
    private var lastLoadedDayKey: String?   // track the last “today” key we loaded

    private lazy var dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = .current
        f.locale = .current
        f.timeZone = .current   // local day boundaries
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    // Expose a small helper so views can derive a dayKey consistently
    func dayKey(for date: Date) -> String {
        dayFormatter.string(from: date)
    }

    // MARK: - Public

    func loadTodayIfNeeded() async {
        let appState = AppState.shared
        if appState.today != nil, !appState.habits.isEmpty {
            appState.isHomeLoadingFirstTime = false
            if visible == nil, let today = appState.today {
                let key = dayKey(for: Date())
                visible = mapTodayToDisplay(today, dayKey: key)
            }
            return
        }
        await load(for: Date())
    }

    func load(for date: Date, force: Bool = false) async {
        let appState = AppState.shared
        let key = dayKey(for: date)
        let isToday = Calendar.current.isDateInToday(date)

        // Cancel any in-flight work for a previous date
        currentTask?.cancel()

        // If it's today and we already have fresh local state, avoid refetch
        if isToday, !force, let today = appState.today {
            self.visible = mapTodayToDisplay(today, dayKey: key)
            appState.isHomeLoadingFirstTime = false
            appState.isHomeLoading = false
            return
        }

        // Loading states: first-time overlay vs. partial overlay
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
                    // store habits (long-lived) + today snapshot
                    AppState.shared.habits = resp.habits
                    AppState.shared.today = DailyDataResponse(
                        todos: resp.todos,
                        upcomingReminders: resp.upcomingReminders,
                        emotionalStates: resp.emotionalStates,
                        transcripts: resp.transcripts
                    )
                    self.visible = self.mapTodayToDisplay(AppState.shared.today!, dayKey: key)
                    self.lastLoadedDayKey = key
                    AppState.shared.isHomeLoadingFirstTime = false
                } else {
                    // PAST day: use cache if available
                    if !force, let cached = pastCache[key] {
                        self.visible = self.mapPastToDisplay(cached, dayKey: key)
                    } else {
                        let resp: PastDayResponse = try await self.fetchPast(forKey: key)
                        pastCache[key] = resp
                        self.visible = self.mapPastToDisplay(resp, dayKey: key)
                    }
                }

                AppState.shared.isHomeLoading = false
            } catch {
                if Task.isCancelled { return }
                print("Load error \(key): \(error.localizedDescription)")
                AppState.shared.isHomeLoading = false
                AppState.shared.isHomeLoadingFirstTime = false
            }
        }

        await currentTask?.value
    }

    /// Force-refresh currently selected date (ignore cache)
    func refresh(for date: Date) async {
        await load(for: date, force: true)
    }

    /// Call this when app becomes active or NSCalendarDayChanged fires.
    func handleDayBoundaryIfNeeded(now: Date = Date()) {
        let appState = AppState.shared
        let newKey = dayKey(for: now)

        guard let lastKey = lastLoadedDayKey, lastKey != newKey else { return }

        // Invalidate today snapshot so the next view of today refetches
        appState.today = nil

        // If the user is viewing "today", move selection to the new day and refresh
        if Calendar.current.isDateInToday(appState.selectedDate) {
            appState.selectedDate = Calendar.current.startOfDay(for: now)
            Task { [weak self] in
                await self?.load(for: appState.selectedDate, force: true)
            }
        }

        lastLoadedDayKey = newKey
    }

    // MARK: - Private networking

    private func fetchToday(forKey dayKey: String) async throws -> DailyDataFullResponse {
        let endpoint = "/daily-data/today"
        let query = [URLQueryItem(name: "day", value: dayKey)]
        return try await APIClient.shared.request(endpoint: endpoint,
                                                  requiresAuth: true,
                                                  queryItems: query
                                                  )
    }

    private func fetchPast(forKey dayKey: String) async throws -> PastDayResponse {
        let endpoint = "/daily-data/past"
        let query = [URLQueryItem(name: "day", value: dayKey)]
        return try await APIClient.shared.request(endpoint: endpoint,
                                                  requiresAuth: true,
                                                  queryItems: query
                                                  )
    }

    // MARK: - Mappers (now set dayKey)

    private func mapTodayToDisplay(_ today: DailyDataResponse, dayKey: String) -> DayDisplay {
        DayDisplay(
            dayKey: dayKey,
            isToday: true,
            todos: today.todos,
            reminders: today.upcomingReminders,
            emotionalStates: today.emotionalStates,
            transcripts: today.transcripts
        )
    }

    private func mapPastToDisplay(_ past: PastDayResponse, dayKey: String) -> DayDisplay {
        DayDisplay(
            dayKey: dayKey,
            isToday: false,
            todos: past.completedTodos,
            reminders: [],
            emotionalStates: past.emotionalStates,
            transcripts: past.transcripts
        )
    }
}
