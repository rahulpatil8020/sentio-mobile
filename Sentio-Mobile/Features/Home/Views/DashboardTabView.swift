import SwiftUI

struct DashboardTabView: View {
    @ObservedObject var vm: HomeViewModel
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                if vm.isLoading {
                    ProgressView("Loading...")
                        .scaleEffect(1.5)
                        .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        // 🟧 Emotional State Card
                        DashboardGridCard(
                            title: "Emotional State",
                            color: .orange,
                            icon: "face.smiling.fill",
                            content: vm.emotionalState?.state ?? "N/A",
                            detail: vm.emotionalState?.note ?? "No note today"
                        )
                        
                        // 🔵 Habits Card
                        DashboardGridCard(
                            title: "Habits",
                            color: .blue,
                            icon: "flame.fill",
                            content: "\(vm.habits.count) Active",
                            detail: vm.habits.first?.title ?? "No habits yet"
                        )
                        
                        // 🟢 Todos Card
                        DashboardGridCard(
                            title: "Todos",
                            color: .green,
                            icon: "checkmark.circle.fill",
                            content: "\(vm.todos.filter { !$0.completed }.count) Pending",
                            detail: vm.todos.first?.title ?? "All caught up!"
                        )
                        
                        // 🟣 Reminders Card
                        DashboardGridCard(
                            title: "Reminders",
                            color: .purple,
                            icon: "bell.fill",
                            content: "\(vm.reminders.count) Upcoming",
                            detail: vm.reminders.first?.title ?? "No reminders"
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Dashboard")

        }
    }
}

#Preview {
    let vm = HomeViewModel()
    vm.habits = [Habit(id: "1", title: "Meditate", description: "10 mins", frequency: "Daily")]
    vm.todos = [Todo(id: "1", title: "Finish project", completed: false, dueDate: nil, priority: 1)]
    vm.reminders = [Reminder(id: "1", title: "Drink Water", remindAt: "2025-07-24T10:00:00Z")]
    vm.emotionalState = EmotionalState(id: "1", state: "Calm", intensity: 7, note: "Had a peaceful morning", date: "2025-07-24")

    return DashboardTabView(vm: vm)
}
