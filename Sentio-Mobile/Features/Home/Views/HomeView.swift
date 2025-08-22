import SwiftUI

struct HomeView: View {
    @ObservedObject private var appState = AppState.shared
    @ObservedObject private var viewModel = HomeViewModel.shared

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                if let user = appState.currentUser {
                    HeaderView(user: user, selectedDate: appState.selectedDate)
                }

                DateSelectorView(selectedDate: $appState.selectedDate)

                // Optional loading/error hint
                if appState.isHomeLoading {
                    ProgressView("Loading…")
                        .tint(Color("Primary"))
                }

                // Journal card
                JournalCard(
                    isProcessing: appState.isProcessingTranscript,
                    lastEntry: (viewModel.visible?.transcripts.first?.text ?? appState.today?.transcripts.first?.text),
                    transcripts: viewModel.visible?.transcripts ?? appState.today?.transcripts ?? []
                )

                // Grid
                LazyVGrid(columns: columns, alignment: .center, spacing: 16) {

                    // Habit progress: habits only come from AppState (fetched with TODAY once)
                    let habits = appState.habits.filter { !$0.isDeleted }
                    HabitCard(
                        completed: habitsCompletedTodayCount(habits),
                        total: habits.count,
                        habits: habits
                    )

                    // Emotions
                    EmotionGraphCard(
                        emotionalStates: viewModel.visible?.emotionalStates
                        ?? appState.today?.emotionalStates
                        ?? []
                    )
                }

                // Todos (today: incomplete; past: completed)
                TodoListCard(
                    todos: viewModel.visible?.todos
                    ?? appState.today?.todos
                    ?? []
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 120)
        }
        .background(Color("Background").ignoresSafeArea())

        // Auto-fetch on appear & whenever the date changes
        .task(id: appState.selectedDate) {
            await viewModel.load(for: appState.selectedDate)
        }
    }

    private func habitsCompletedTodayCount(_ habits: [Habit]) -> Int {
        let cal = Calendar.current
        return habits.filter { h in
            if let last = h.streak.lastCompletedDate, cal.isDateInToday(last) { return true }
            return h.completions.contains { cal.isDateInToday($0.date) }
        }.count
    }
}

#Preview {
    struct HomeViewPreview: View {
        init() {
            AppState.shared.currentUser = User(
                id: "123",
                name: "Rahul Patil",
                email: "rahul@example.com",
                createdAt: "2025-08-02T12:00:00Z",
                isOnboarded: true,
                city: "San Francisco",
                country: "USA",
                profession: "Software Engineer",
                goals: ["Personal growth", "Fitness"]
            )
        }
        var body: some View {
            HomeView()
                .environment(\.colorScheme, .dark)
        }
    }
    return HomeViewPreview()
}
