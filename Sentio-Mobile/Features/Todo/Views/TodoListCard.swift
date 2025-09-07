import SwiftUI

// MARK: - Card
struct TodoListCard: View {
    // Incoming data from parent (always reflects the latest fetch)
    let items: [Todo]

    // Local mutable copy for UI edits (add, sort, etc.)
    @State private var todos: [Todo] = []
    @State private var showAll = false
    @State private var showAdd = false

    init(todos: [Todo]) {
        self.items = todos
        _todos = State(initialValue: todos)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Text("Task List")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
                Button { showAdd = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                        .padding(10)
                        .background(Color.white.opacity(0.06))
                        .clipShape(Circle())
                }
            }

            // Content
            if todos.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checklist.unchecked")
                        .font(.system(size: 42))
                        .foregroundColor(Color("TextSecondary"))

                    Text("No tasks yet")
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))

                    Text("Add your first task to stay organized.")
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 120)
                .padding(.vertical, 8)
            } else {
                // Top 4 by priority
                VStack(spacing: 10) {
                    ForEach(topFour) { todo in
                        TodoRow(todo: todo)
                    }
                }

                if todos.count > 4 {
                    Button { showAll = true } label: {
                        HStack(spacing: 6) {
                            Text("Show more")
                            Image(systemName: "chevron.right").font(.caption)
                        }
                        .font(.callout.weight(.semibold))
                        .foregroundColor(Color("TextSecondary"))
                        .padding(.top, 2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(Color("Surface"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        // Full-screen list of all todos
        .fullScreenCover(isPresented: $showAll) {
            AllTodosView(todos: $todos)
        }
        // Add todo sheet
        .sheet(isPresented: $showAdd) {
            AddTodoSheet { newTodo in
                todos.append(newTodo)
                todos = sorted(todos)
            }
            .presentationDetents([.height(420), .medium])
            .background(Color("Background").ignoresSafeArea())
        }
        // 🔄 Keep local state in sync with incoming prop whenever parent updates
        .onChange(of: items) { newItems in
            todos = sorted(newItems)
        }
    }

    private var topFour: [Todo] {
        Array(sorted(todos).prefix(4))
    }

    /// Sort: priority desc (10 highest), then earliest due date, then createdAt
    private func sorted(_ list: [Todo]) -> [Todo] {
        list.sorted { a, b in
            if a.priority != b.priority { return a.priority > b.priority }
            switch (a.dueDate, b.dueDate) {
            case let (da?, db?):
                if da != db { return da < db }
            case (nil, _?):
                return false
            case (_?, nil):
                return true
            default: break
            }
            return a.createdAt < b.createdAt
        }
    }
}
// MARK: - Row
struct TodoRow: View {
    let todo: Todo

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox look (non-interactive for now)
            Circle()
                .fill(todo.completed ? Color.green.opacity(0.7) : Color.gray.opacity(0.35))
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(todo.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color("TextPrimary"))
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    PriorityBadge(priority: todo.priority)
                }
                if let due = todo.dueDate {
                    Text("Due \(due.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                }
            }

            Spacer()

            // Edit / Delete placeholders (no actions yet)
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("TextSecondary"))
                }
                Button(action: {}) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("TextSecondary"))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Priority Badge (10 highest)
struct PriorityBadge: View {
    let priority: Int

    var body: some View {
        let (label, color): (String, Color) = {
            switch priority {
            case 9...10: return ("P\(priority)", .red)       // Highest
            case 7...8:  return ("P\(priority)", .orange)
            case 5...6:  return ("P\(priority)", .yellow)
            case 3...4:  return ("P\(priority)", .mint)
            default:     return ("P\(priority)", .gray)      // 1-2 lowest
            }
        }()

        return Text(label)
            .font(.caption2.weight(.bold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

// MARK: - All Todos Full Screen
struct AllTodosView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var todos: [Todo]

    var body: some View {
        NavigationStack {
            if todos.isEmpty {
                // Empty-state inside the full list too (defensive)
                VStack(spacing: 12) {
                    Image(systemName: "checklist.unchecked")
                        .font(.system(size: 42))
                        .foregroundColor(Color("TextSecondary"))
                    Text("No tasks to show")
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                    Text("Create a task to get started.")
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("Background").ignoresSafeArea())
                .navigationTitle("All Tasks")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close") { dismiss() }
                    }
                }
            } else {
                List {
                    ForEach(sorted(todos)) { todo in
                        TodoRow(todo: todo)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color("Background").ignoresSafeArea())
                .navigationTitle("All Tasks")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close") { dismiss() }
                    }
                }
            }
        }
        .background(Color("Background").ignoresSafeArea())
    }

    private func sorted(_ list: [Todo]) -> [Todo] {
        list.sorted { a, b in
            if a.priority != b.priority { return a.priority > b.priority } // 10 highest first
            switch (a.dueDate, b.dueDate) {
            case let (da?, db?):
                if da != db { return da < db }
            case (nil, _?):
                return false
            case (_?, nil):
                return true
            default: break
            }
            return a.createdAt < b.createdAt
        }
    }
}

// MARK: - Add Todo Sheet (small modal)
struct AddTodoSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var dueDate: Date? = nil
    @State private var hasDueDate = false
    @State private var priority: Int = 5   // mid by default

    let onAdd: (Todo) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                }

                Section("Priority (1–10)") {
                    HStack {
                        Picker("", selection: $priority) {
                            Text("1").tag(1)
                            Text("3").tag(3)
                            Text("5").tag(5)
                            Text("7").tag(7)
                            Text("10").tag(10)
                        }
                        .pickerStyle(.segmented)
                    }
                    Stepper("Set: \(priority)", value: $priority, in: 1...10)
                }

                Section("Due Date") {
                    Toggle("Set due date", isOn: $hasDueDate.animation())
                    if hasDueDate {
                        DatePicker("Due", selection: Binding(
                            get: { dueDate ?? Date() },
                            set: { dueDate = $0 }
                        ), displayedComponents: .date)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("Background").ignoresSafeArea())
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let todo = Todo(
                            id: UUID().uuidString,
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            completed: false,
                            dueDate: hasDueDate ? dueDate : nil,
                            createdBy: "me",
                            createdAt: Date(),
                            priority: priority,
                            completedAt: nil,
                            userId: "u1"
                        )
                        onAdd(todo)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .background(Color("Background").ignoresSafeArea())
    }
}

// MARK: - Preview
#Preview("With Tasks") {
    let sampleTodos: [Todo] = [
        .init(
            id: "t1",
            title: "Finish SwiftUI Module",
            completed: false,
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
            createdBy: "rahul",
            createdAt: Date().addingTimeInterval(-80000),
            priority: 9,
            completedAt: nil,
            userId: "u1"
        ),
        .init(
            id: "t2",
            title: "Morning Workout",
            completed: true,
            dueDate: nil,
            createdBy: "rahul",
            createdAt: Date().addingTimeInterval(-70000),
            priority: 6,
            completedAt: Date().addingTimeInterval(-2000),
            userId: "u1"
        ),
        .init(
            id: "t3",
            title: "Prepare Presentation Slides",
            completed: false,
            dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
            createdBy: "rahul",
            createdAt: Date().addingTimeInterval(-60000),
            priority: 8,
            completedAt: nil,
            userId: "u1"
        ),
        .init(
            id: "t4",
            title: "Doctor Appointment",
            completed: false,
            dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
            createdBy: "rahul",
            createdAt: Date().addingTimeInterval(-50000),
            priority: 7,
            completedAt: nil,
            userId: "u1"
        ),
        .init(
            id: "t5",
            title: "Call Parents",
            completed: true,
            dueDate: nil,
            createdBy: "rahul",
            createdAt: Date().addingTimeInterval(-40000),
            priority: 4,
            completedAt: Date().addingTimeInterval(-10000),
            userId: "u1"
        ),
        .init(
            id: "t6",
            title: "Plan Weekend Trip",
            completed: false,
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
            createdBy: "rahul",
            createdAt: Date().addingTimeInterval(-30000),
            priority: 5,
            completedAt: nil,
            userId: "u1"
        )
    ]

    ScrollView {
        TodoListCard(todos: sampleTodos)
            .padding()
    }
    .background(Color("Background"))
    .environment(\.colorScheme, .dark)
}

#Preview("Empty State") {
    ScrollView {
        TodoListCard(todos: [])
            .padding()
    }
    .background(Color("Background"))
    .environment(\.colorScheme, .dark)
}
