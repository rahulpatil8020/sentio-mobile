import SwiftUI

struct HabitsDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var appState = AppState.shared

    @State private var habits: [Habit]
    @State private var selectedHabit: Habit? = nil
    @State private var showAddSheet = false

    init(initialHabits: [Habit]) {
        _habits = State(initialValue: initialHabits)
    }

    private var activeHabits: [Habit] {
        habits.filter { !$0.isDeleted }
    }

    private var sortedHabits: [Habit] {
        activeHabits.sorted { a, b in
            if a.isAccepted != b.isAccepted { return a.isAccepted == false }
            if rank(a.frequency) != rank(b.frequency) { return rank(a.frequency) < rank(b.frequency) }
            return a.title.localizedCaseInsensitiveCompare(b.title) == .orderedAscending
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if activeHabits.isEmpty {
                        EmptyHabitsView(onAdd: { showAddSheet = true })
                            .padding(.top, 48)
                    } else {
                        ForEach(sortedHabits) { habit in
                            HabitRow(
                                habit: habit,
                                day: appState.selectedDate,
                                onAccept: { handleAccept(habitID: habit.id) },
                                onReject: { handleReject(habitID: habit.id) },
                                onCompleteToggle: { handleToggleComplete(on: appState.selectedDate, habitID: habit.id) },
                                onOpenDetails: { selectedHabit = habit }
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Color("Background").ignoresSafeArea())
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus").font(.body.weight(.bold))
                    }
                    .accessibilityLabel("Add Habit")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddHabitSheet { newHabit in habits.append(newHabit) }
                    .presentationDetents([.medium, .large])
                    .background(Color("Background").ignoresSafeArea())
            }
            .sheet(item: $selectedHabit) { habit in
                if let idx = habits.firstIndex(where: { $0.id == habit.id }) {
                    HabitEditView(
                        habit: habits[idx],
                        onSave: { updated in habits[idx] = updated },
                        onDelete: {
                            var h = habits[idx]
                            h = Habit(
                                id: h.id, title: h.title, description: h.description,
                                createdAt: h.createdAt, updatedAt: Date(),
                                startDate: h.startDate, endDate: h.endDate,
                                frequency: h.frequency, reminderTime: h.reminderTime,
                                streak: h.streak, completions: h.completions,
                                isDeleted: true, isAccepted: h.isAccepted
                            )
                            habits[idx] = h
                        }
                    )
                    .presentationDetents([.large])
                    .background(Color("Background").ignoresSafeArea())
                } else {
                    Text("Habit not found")
                        .padding()
                        .background(Color("Background").ignoresSafeArea())
                }
            }
        }
        .background(Color("Background").ignoresSafeArea())
    }

    // MARK: - Local actions (replace with backend calls when wiring)
    private func handleAccept(habitID: String) {
        guard let idx = habits.firstIndex(where: { $0.id == habitID }) else { return }
        let h = habits[idx]
        habits[idx] = Habit(
            id: h.id, title: h.title, description: h.description,
            createdAt: h.createdAt, updatedAt: Date(),
            startDate: h.startDate, endDate: h.endDate,
            frequency: h.frequency, reminderTime: h.reminderTime,
            streak: h.streak, completions: h.completions,
            isDeleted: h.isDeleted, isAccepted: true
        )
    }

    private func handleReject(habitID: String) {
        guard let idx = habits.firstIndex(where: { $0.id == habitID }) else { return }
        let h = habits[idx]
        habits[idx] = Habit(
            id: h.id, title: h.title, description: h.description,
            createdAt: h.createdAt, updatedAt: Date(),
            startDate: h.startDate, endDate: h.endDate,
            frequency: h.frequency, reminderTime: h.reminderTime,
            streak: h.streak, completions: h.completions,
            isDeleted: true, isAccepted: h.isAccepted
        )
    }

    /// Toggle complete for the **selected day**.
    /// If day is today → also adjusts streak; otherwise only touches completions.
    private func handleToggleComplete(on day: Date, habitID: String) {
        guard let idx = habits.firstIndex(where: { $0.id == habitID }) else { return }
        var h = habits[idx]
        guard h.isAccepted else { return }

        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: day)

        let hasForDay = h.completions.contains { cal.isDate($0.date, inSameDayAs: startOfDay) }
            || (h.streak.lastCompletedDate.map { cal.isDate($0, inSameDayAs: startOfDay) } ?? false)

        if hasForDay {
            var comps = h.completions.filter { !cal.isDate($0.date, inSameDayAs: startOfDay) }
            if cal.isDateInToday(day) {
                let newCurrent = max(0, h.streak.current - 1)
                h = Habit(
                    id: h.id, title: h.title, description: h.description,
                    createdAt: h.createdAt, updatedAt: Date(),
                    startDate: h.startDate, endDate: h.endDate,
                    frequency: h.frequency, reminderTime: h.reminderTime,
                    streak: Streak(current: newCurrent, longest: h.streak.longest, lastCompletedDate: mostRecentDate(in: comps)),
                    completions: comps,
                    isDeleted: h.isDeleted, isAccepted: h.isAccepted
                )
            } else {
                h = Habit(
                    id: h.id, title: h.title, description: h.description,
                    createdAt: h.createdAt, updatedAt: Date(),
                    startDate: h.startDate, endDate: h.endDate,
                    frequency: h.frequency, reminderTime: h.reminderTime,
                    streak: h.streak,
                    completions: comps,
                    isDeleted: h.isDeleted, isAccepted: h.isAccepted
                )
            }
        } else {
            var comps = h.completions
            comps.append(Completion(date: startOfDay))
            if cal.isDateInToday(day) {
                let newCurrent = h.streak.current + 1
                let newLongest = max(h.streak.longest, newCurrent)
                h = Habit(
                    id: h.id, title: h.title, description: h.description,
                    createdAt: h.createdAt, updatedAt: Date(),
                    startDate: h.startDate, endDate: h.endDate,
                    frequency: h.frequency, reminderTime: h.reminderTime,
                    streak: Streak(current: newCurrent, longest: newLongest, lastCompletedDate: startOfDay),
                    completions: comps,
                    isDeleted: h.isDeleted, isAccepted: h.isAccepted
                )
            } else {
                h = Habit(
                    id: h.id, title: h.title, description: h.description,
                    createdAt: h.createdAt, updatedAt: Date(),
                    startDate: h.startDate, endDate: h.endDate,
                    frequency: h.frequency, reminderTime: h.reminderTime,
                    streak: h.streak,
                    completions: comps,
                    isDeleted: h.isDeleted, isAccepted: h.isAccepted
                )
            }
        }
        habits[idx] = h
    }

    private func mostRecentDate(in comps: [Completion]) -> Date? {
        comps.max(by: { $0.date < $1.date })?.date
    }

    private func rank(_ freq: String) -> Int {
        switch freq.lowercased() {
        case "daily": return 0
        case "weekly": return 1
        case "monthly": return 2
        default: return 3
        }
    }
}

// MARK: - Small empty state view
private struct EmptyHabitsView: View {
    let onAdd: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.circle")
                .font(.system(size: 44))
                .foregroundColor(Color("TextSecondary"))
            Text("No active habits")
                .font(.title3.bold())
                .foregroundColor(Color("TextPrimary"))
            Text("Accepted habits appear here. You can accept or reject suggestions anytime, or add your own.")
                .font(.subheadline)
                .foregroundColor(Color("TextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button(action: onAdd) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add a habit")
                }
                .font(.callout.weight(.semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color("Primary"))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }
}
