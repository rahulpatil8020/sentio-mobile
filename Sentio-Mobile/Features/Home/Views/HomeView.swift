import SwiftUI

struct HomeView: View {
    @ObservedObject private var appState = AppState.shared
    @StateObject private var viewModel = HomeViewModel.shared
    
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
                
                    JournalCard(
                        isProcessing: appState.isProcessingTranscript,
                        lastEntry: appState.lastJournalSnippet
                    )
                    
                    LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                        HabitCard(completed: 5, total: 8, habits:  [
                            Habit(
                                id: "1",
                                title: "Morning Run",
                                description: "Run at least 2km",
                                createdAt: Date(),
                                updatedAt: nil,
                                startDate: Date(),
                                endDate: nil,
                                frequency: "daily",
                                reminderTime: "07:00 AM",
                                streak: Streak(current: 5, longest: 10, lastCompletedDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())),
                                completions: [Completion(date: Date())],
                                isDeleted: false,
                                isAccepted: true
                            ),
                            Habit(
                                id: "2",
                                title: "Read Book",
                                description: "Read 10 pages",
                                createdAt: Date(),
                                updatedAt: nil,
                                startDate: Date(),
                                endDate: nil,
                                frequency: "daily",
                                reminderTime: "09:00 PM",
                                streak: Streak(current: 2, longest: 7, lastCompletedDate: nil),
                                completions: [],
                                isDeleted: false,
                                isAccepted: false // Pending habit
                            ),
                            Habit(
                                id: "3",
                                title: "Meditation",
                                description: "10 minutes mindfulness",
                                createdAt: Date(),
                                updatedAt: nil,
                                startDate: Date(),
                                endDate: nil,
                                frequency: "weekly",
                                reminderTime: nil,
                                streak: Streak(current: 0, longest: 3, lastCompletedDate: nil),
                                completions: [],
                                isDeleted: false,
                                isAccepted: true
                            )
                        ]
)

                        EmotionGraphCard(emotionalStates: [
                            EmotionalState(id: "1", state: "Angry", intensity: 8, note: "bad traffic", createdAt: Date().addingTimeInterval(-3600 * 6)),
                            EmotionalState(id: "2", state: "Sad", intensity: 4, note: nil, createdAt: Date().addingTimeInterval(-3600 * 5)),
                            EmotionalState(id: "3", state: "Calm", intensity: 6, note: nil, createdAt: Date().addingTimeInterval(-3600 * 4)),
                            EmotionalState(id: "4", state: "Happy", intensity: 8, note: "got compliment", createdAt: Date().addingTimeInterval(-3600 * 2)),
                        ])
                    }
                    TodoListCard(todos: [
                        Todo(
                            id: "todo1",
                            title: "Finish journal entry",
                            completed: false,
                            dueDate: Date().addingTimeInterval(3600), // in 1 hour
                            createdBy: "USER",
                            createdAt: Date().addingTimeInterval(-3600), // 1 hour ago
                            priority: 2,
                            completedAt: nil
                        ),
                        Todo(
                            id: "todo2",
                            title: "Read for 30 minutes",
                            completed: true,
                            dueDate: nil,
                            createdBy: "AI",
                            createdAt: Date().addingTimeInterval(-86400), // yesterday
                            priority: 5,
                            completedAt: Date().addingTimeInterval(-1800)
                        ),
                        Todo(
                            id: "todo3",
                            title: "Make Dinner",
                            completed: false,
                            dueDate: Date().addingTimeInterval(3600), // in 1 hour
                            createdBy: "USER",
                            createdAt: Date().addingTimeInterval(-3600), // 1 hour ago
                            priority: 4,
                            completedAt: nil
                        ),
                        Todo(
                            id: "todo4",
                            title: "Code the block",
                            completed: true,
                            dueDate: nil,
                            createdBy: "AI",
                            createdAt: Date().addingTimeInterval(-86400), // yesterday
                            priority: 8,
                            completedAt: Date().addingTimeInterval(-1800)
                        ),
                        Todo(
                            id: "todo5",
                            title: "Make Anime figure",
                            completed: false,
                            dueDate: Date().addingTimeInterval(3600), // in 1 hour
                            createdBy: "USER",
                            createdAt: Date().addingTimeInterval(-3600), // 1 hour ago
                            priority: 2,
                            completedAt: nil
                        ),
                        Todo(
                            id: "todo6",
                            title: "Clean Glasses",
                            completed: true,
                            dueDate: nil,
                            createdBy: "AI",
                            createdAt: Date().addingTimeInterval(-86400), // yesterday
                            priority: 6,
                            completedAt: Date().addingTimeInterval(-1800)
                        )
                    ])
                }
                .padding(.horizontal)
                .padding(.bottom, 120)
            }
        .onAppear {
            Task {
                await viewModel.loadTodayIfNeeded()
            }
        }
        .background(Color("Background").ignoresSafeArea())
        
    }
}
#Preview {
    struct HomeViewPreview: View {
        init() {
            // Inject a mock user into AppState for preview
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
                .environment(\.colorScheme, .dark) // 👈 Preview in dark mode
        }
    }
    
    return HomeViewPreview()
}
