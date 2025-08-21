import SwiftUI

import SwiftUI

struct HabitsDetailView: View {
    @Environment(\.dismiss) private var dismiss

    // Local mutable copy for UX
    @State private var habits: [Habit]
    @State private var selectedHabit: Habit? = nil   // used by sheet(item:)

    init(initialHabits: [Habit]) {
        _habits = State(initialValue: initialHabits)
    }

    private var activeHabits: [Habit] {
        habits.filter { !$0.isDeleted }
    }

    // Sort: pending first → frequency → title
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
                        VStack(spacing: 12) {
                            Text("No active habits")
                                .font(.title3.bold())
                                .foregroundColor(Color("TextPrimary"))
                            Text("Accepted habits appear here. You can accept or reject suggestions anytime.")
                                .font(.subheadline)
                                .foregroundColor(Color("TextSecondary"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
                        ForEach(sortedHabits) { habit in
                            HabitRow(
                                habit: habit,
                                onAccept: { handleAccept(habitID: habit.id) },
                                onReject: { handleReject(habitID: habit.id) },
                                onCompleteToggle: { handleToggleCompleteToday(habitID: habit.id) },
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
            }
            // ✅ Use sheet(item:) so the modal always appears
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
                    // Fallback if index not found
                    Text("Habit not found")
                        .padding()
                        .background(Color("Background").ignoresSafeArea())
                }
            }
        }
        .background(Color("Background").ignoresSafeArea())
    }

    // MARK: - Actions (local; replace with backend calls)
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

    // Toggle complete for today (accepted habits only; guard in row too)
    private func handleToggleCompleteToday(habitID: String) {
        guard let idx = habits.firstIndex(where: { $0.id == habitID }) else { return }
        var h = habits[idx]
        guard h.isAccepted else { return } // extra guard

        let cal = Calendar.current
        let today = Date()
        let hasToday = h.completions.contains { cal.isDateInToday($0.date) }
            || (h.streak.lastCompletedDate.map { cal.isDateInToday($0) } ?? false)

        if hasToday {
            // Remove today's completion
            var comps = h.completions.filter { !cal.isDateInToday($0.date) }
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
            var comps = h.completions
            comps.append(Completion(date: today))
            let newCurrent = h.streak.current + 1
            let newLongest = max(h.streak.longest, newCurrent)
            h = Habit(
                id: h.id, title: h.title, description: h.description,
                createdAt: h.createdAt, updatedAt: Date(),
                startDate: h.startDate, endDate: h.endDate,
                frequency: h.frequency, reminderTime: h.reminderTime,
                streak: Streak(current: newCurrent, longest: newLongest, lastCompletedDate: today),
                completions: comps,
                isDeleted: h.isDeleted, isAccepted: h.isAccepted
            )
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

struct StreakBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}


struct FrequencyBadge: View {
    let text: String

    var body: some View {
        let color: Color = {
            switch text.lowercased() {
            case "daily": return .teal
            case "weekly": return .orange
            case "monthly": return .purple
            default: return .gray
            }
        }()

        return Text(text.capitalized)
            .font(.caption2.weight(.bold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}


struct HabitRow: View {
    let habit: Habit
    let onAccept: () -> Void
    let onReject: () -> Void
    let onCompleteToggle: () -> Void
    let onOpenDetails: () -> Void

    private var completedToday: Bool {
        let cal = Calendar.current
        if let last = habit.streak.lastCompletedDate, cal.isDateInToday(last) { return true }
        return habit.completions.contains { cal.isDateInToday($0.date) }
    }

    var body: some View {
        VStack(spacing: 10) {
            // Row 1: Title + actions
            HStack(spacing: 12) {
                // Left indicator:
                // - Accepted: tappable toggle to mark complete/incomplete
                // - Pending: non-interactive gray dot (no completion allowed)
                if habit.isAccepted {
                    Button(action: onCompleteToggle) {
                        Circle()
                            .fill(completedToday ? Color.green.opacity(0.8) : Color.gray.opacity(0.35))
                            .frame(width: 26, height: 26)
                            .overlay(
                                Image(systemName: completedToday ? "checkmark" : "plus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white.opacity(0.95))
                            )
                            .accessibilityLabel(completedToday ? "Mark incomplete" : "Mark complete")
                    }
                    .buttonStyle(.plain)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.35))
                        .frame(width: 26, height: 26)
                        .overlay(
                            Text("⏳").font(.system(size: 11))
                        )
                        .accessibilityHidden(true)
                }

                // Title (tap to open details)
                Button(action: onOpenDetails) {
                    Text(habit.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color("TextPrimary"))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)

                // Right side: pending actions or chevron
                if habit.isAccepted {
                    Button(action: onOpenDetails) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color("TextSecondary"))
                    }.buttonStyle(.plain)
                } else {
                    HStack(spacing: 8) {
                        Button(action: onReject) {
                            Text("Reject")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        Button(action: onAccept) {
                            Text("Accept")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }
                }
            }

            // Row 2: Badges (under the title)
            HStack(spacing: 8) {
                FrequencyBadge(text: habit.frequency)
                if habit.streak.current > 0 {
                    StreakBadge(text: "🔥 \(habit.streak.current)", color: .red)
                }
                if habit.streak.longest > 0 {
                    StreakBadge(text: "🏆 \(habit.streak.longest)", color: .yellow)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Row 3: meta (reminder, description, last completed)
            HStack(spacing: 8) {
                if let time = habit.reminderTime, !time.isEmpty {
                    Label(time, systemImage: "bell")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                }
                if let desc = habit.description, !desc.isEmpty {
                    Text("• \(desc)")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                if let last = habit.streak.lastCompletedDate {
                    Text("• Last: \(last.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Row 4: dates (start/end)
            HStack(spacing: 12) {
                Label("Start \(habit.startDate.formatted(date: .abbreviated, time: .omitted))", systemImage: "calendar.badge.plus")
                    .font(.caption2)
                    .foregroundColor(Color("TextSecondary"))

                if let end = habit.endDate {
                    Label("Ends \(end.formatted(date: .abbreviated, time: .omitted))", systemImage: "calendar.badge.minus")
                        .font(.caption2)
                        .foregroundColor(Color("TextSecondary"))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}


struct HabitEditView: View {
    @Environment(\.dismiss) private var dismiss

    @State var habit: Habit
    let onSave: (Habit) -> Void
    let onDelete: () -> Void

    @State private var title: String = ""
    @State private var descriptionText: String = ""
    @State private var frequency: String = "daily"
    @State private var reminderTime: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date? = nil
    @State private var hasEndDate: Bool = false
    @State private var isAccepted: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $descriptionText, axis: .vertical)
                        .lineLimit(1...3)

                    Picker("Frequency", selection: $frequency) {
                        Text("Daily").tag("daily")
                        Text("Weekly").tag("weekly")
                        Text("Monthly").tag("monthly")
                    }
                    .pickerStyle(.segmented)

                    TextField("Reminder (e.g. 07:00 AM)", text: $reminderTime)
                }

                Section("Dates") {
                    DatePicker("Start", selection: $startDate, displayedComponents: .date)
                    Toggle("Set end date", isOn: $hasEndDate.animation())
                    if hasEndDate {
                        DatePicker("End", selection: Binding(
                            get: { endDate ?? Date() },
                            set: { endDate = $0 }
                        ), displayedComponents: .date)
                    }
                }

                Section("Status") {
                    Toggle("Accepted", isOn: $isAccepted)
                }

                Section {
                    Button(role: .destructive) {
                        onDelete()
                        dismiss()
                    } label: {
                        HStack { Spacer(); Text("Delete Habit"); Spacer() }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("Background").ignoresSafeArea())
            .navigationTitle("Edit Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updated = Habit(
                            id: habit.id,
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            description: descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                            createdAt: habit.createdAt,
                            updatedAt: Date(),
                            startDate: startDate,
                            endDate: hasEndDate ? endDate : nil,
                            frequency: frequency,
                            reminderTime: reminderTime.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                            streak: habit.streak,
                            completions: habit.completions,
                            isDeleted: habit.isDeleted,
                            isAccepted: isAccepted
                        )
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            // seed UI
            title = habit.title
            descriptionText = habit.description ?? ""
            frequency = habit.frequency
            reminderTime = habit.reminderTime ?? ""
            startDate = habit.startDate
            endDate = habit.endDate
            hasEndDate = habit.endDate != nil
            isAccepted = habit.isAccepted
        }
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}

// MARK: - Mock Data for Previews
extension Habit {
    static var previewHabits: [Habit] {
        let cal = Calendar.current
        let today = Date()
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = cal.date(byAdding: .day, value: -2, to: today)!

        return [
            Habit(
                id: "h1",
                title: "Morning Run",
                description: "Run at least 2km",
                createdAt: twoDaysAgo,
                updatedAt: nil,
                startDate: twoDaysAgo,
                endDate: nil,
                frequency: "daily",
                reminderTime: "07:00 AM",
                streak: Streak(current: 5, longest: 12, lastCompletedDate: yesterday),
                completions: [Completion(date: today)], // done today
                isDeleted: false,
                isAccepted: true
            ),
            Habit(
                id: "h2",
                title: "Read Book",
                description: "Read 20 pages of non-fiction",
                createdAt: twoDaysAgo,
                updatedAt: nil,
                startDate: twoDaysAgo,
                endDate: nil,
                frequency: "daily",
                reminderTime: "09:00 PM",
                streak: Streak(current: 2, longest: 4, lastCompletedDate: twoDaysAgo),
                completions: [], // not done today
                isDeleted: false,
                isAccepted: true
            ),
            Habit(
                id: "h3",
                title: "Meditation",
                description: "15 minutes mindfulness practice",
                createdAt: twoDaysAgo,
                updatedAt: nil,
                startDate: twoDaysAgo,
                endDate: nil,
                frequency: "weekly",
                reminderTime: nil,
                streak: Streak(current: 0, longest: 3, lastCompletedDate: nil),
                completions: [],
                isDeleted: false,
                isAccepted: false // pending → shows Accept/Reject
            ),
            Habit(
                id: "h4",
                title: "Stretching Routine",
                description: "5-minute mobility",
                createdAt: twoDaysAgo,
                updatedAt: nil,
                startDate: twoDaysAgo,
                endDate: nil,
                frequency: "monthly",
                reminderTime: "08:00 AM",
                streak: Streak(current: 1, longest: 2, lastCompletedDate: twoDaysAgo),
                completions: [],
                isDeleted: false,
                isAccepted: true
            )
        ]
    }
}

// MARK: - Previews
#Preview("Habits Fullscreen") {
    HabitsDetailView(initialHabits: Habit.previewHabits)
        .environment(\.colorScheme, .dark)
}

#Preview("Habit Row - Accepted") {
    HabitRow(
        habit: Habit.previewHabits.first!, // Morning Run
        onAccept: {},
        onReject: {},
        onCompleteToggle: {},
        onOpenDetails: {}
    )
    .padding()
    .background(Color("Background"))
    .environment(\.colorScheme, .dark)
}

#Preview("Habit Row - Pending") {
    // Find the pending one
    let pending = Habit.previewHabits.first { !$0.isAccepted }!
    return HabitRow(
        habit: pending,
        onAccept: {},
        onReject: {},
        onCompleteToggle: {},
        onOpenDetails: {}
    )
    .padding()
    .background(Color("Background"))
    .environment(\.colorScheme, .dark)
}
