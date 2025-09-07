import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    static let shared = HomeViewModel()
    private init() {}

    @Published var visible: DayDisplay? = nil

    private var pastCache: [String: PastDayData] = [:]
    private var currentTask: Task<Void, Never>?
    private var lastLoadedDayKey: String?

    private lazy var dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = .current
        f.locale = .current
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

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

        currentTask?.cancel()

        if isToday, !force, let today = appState.today {
            self.visible = mapTodayToDisplay(today, dayKey: key)
            appState.isHomeLoadingFirstTime = false
            appState.isHomeLoading = false
            return
        }

        if isToday, appState.isHomeLoadingFirstTime {
            appState.isHomeLoadingFirstTime = true
        } else {
            appState.isHomeLoading = true
        }

        currentTask = Task { [weak self] in
            guard let self else { return }

            do {
                if isToday {
                    let resp = try await self.fetchToday(forKey: key)
                    guard resp.success else {
                        throw NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: resp.message])
                    }
                    let data = resp.data
                    AppState.shared.habits = data.habits
                    AppState.shared.today = DailyData(
                        todos: data.incompleteTodos,
                        upcomingReminders: data.upcomingReminders,
                        emotionalStates: data.emotionalStates,
                        transcripts: data.transcripts
                    )
                    self.visible = self.mapTodayToDisplay(AppState.shared.today!, dayKey: key)
                    self.lastLoadedDayKey = key
                    AppState.shared.isHomeLoadingFirstTime = false
                } else {
                    if !force, let cached = pastCache[key] {
                        self.visible = self.mapPastToDisplay(cached, dayKey: key)
                    } else {
                        let resp = try await self.fetchPast(forKey: key)
                        guard resp.success else {
                            throw NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: resp.message])
                        }
                        let data = resp.data
                        pastCache[key] = data
                        self.visible = self.mapPastToDisplay(data, dayKey: key)
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

    func refresh(for date: Date) async {
        await load(for: date, force: true)
    }

    func handleDayBoundaryIfNeeded(now: Date = Date()) {
        let appState = AppState.shared
        let newKey = dayKey(for: now)

        guard let lastKey = lastLoadedDayKey, lastKey != newKey else { return }

        appState.today = nil

        if Calendar.current.isDateInToday(appState.selectedDate) {
            appState.selectedDate = Calendar.current.startOfDay(for: now)
            Task { [weak self] in
                await self?.load(for: appState.selectedDate, force: true)
            }
        }

        lastLoadedDayKey = newKey
    }

    // MARK: - Networking

    private func fetchToday(forKey dayKey: String) async throws -> DailyDataFullResponse {
        let endpoint = "/daily-data/today"
        let query = [URLQueryItem(name: "day", value: dayKey)]
        return try await APIClient.shared.request(endpoint: endpoint,
                                                  requiresAuth: true,
                                                  queryItems: query)
    }

    private func fetchPast(forKey dayKey: String) async throws -> PastDayResponse {
        let endpoint = "/daily-data/past"
        let query = [URLQueryItem(name: "day", value: dayKey)]
        return try await APIClient.shared.request(endpoint: endpoint,
                                                  requiresAuth: true,
                                                  queryItems: query)
    }

    // MARK: - Mappers

    private func mapTodayToDisplay(_ today: DailyData, dayKey: String) -> DayDisplay {
        DayDisplay(
            dayKey: dayKey,
            isToday: true,
            todos: today.todos,
            reminders: today.upcomingReminders,
            emotionalStates: today.emotionalStates,
            transcripts: today.transcripts
        )
    }

    private func mapPastToDisplay(_ past: PastDayData, dayKey: String) -> DayDisplay {
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
