import SwiftUI

// MARK: - Card
struct HabitCard: View {
    let habits: [Habit]
    let selectedDate: Date

    @State private var showDetails = false

    private var activeHabits: [Habit] {
        habits.filter { !$0.isDeleted && $0.isAccepted }
    }

    private var pendingExists: Bool {
        habits.contains { !$0.isDeleted && !$0.isAccepted }
    }

    // MARK: - Derived values
    private var total: Int { activeHabits.count }

    private var completed: Int {
        let cal = Calendar.current
        return activeHabits.filter { h in
            let didCompleteFromCompletions = h.completions.contains {
                cal.isDate($0.date, inSameDayAs: selectedDate)
            }
            let didCompleteFromStreak = h.streak.lastCompletedDate.map {
                cal.isDate($0, inSameDayAs: selectedDate)
            } ?? false
            return didCompleteFromCompletions || didCompleteFromStreak
        }.count
    }

    private var progress: Double {
        total == 0 ? 0 : Double(completed) / Double(total)
    }

    private var remaining: Int {
        max(0, total - completed)
    }

    private var progressColor: Color {
        let hue = 0.16 + (0.17 * progress)   // yellow → green
        let saturation = 0.9
        let brightness = 0.9 - (0.2 * (1 - progress))
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }

    var body: some View {
        Button { showDetails = true } label: {
            VStack(alignment: .center, spacing: 12) {
                Text("Track your Habits")
                    .font(.headline)
                    .foregroundColor(Color("TextPrimary"))

                if activeHabits.isEmpty {
                    // Empty State
                    VStack(spacing: 10) {
                        Image(systemName: "leaf.circle")
                            .font(.system(size: 40))
                            .foregroundColor(Color("TextSecondary"))
                        Text("No habits yet")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Color("TextPrimary"))
                        Text("Add or accept a habit to start building your streaks.")
                            .font(.caption)
                            .foregroundColor(Color("TextSecondary"))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Normal State
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 10)

                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                progressColor,
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.easeOut(duration: 0.6), value: progress)

                        Text("\(completed)/\(total)")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    .frame(width: 80, height: 80)
                    // 👇 Dot on the circle’s top-right corner
                    .overlay(alignment: .topTrailing) {
                        if pendingExists {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                                .offset(x: 6, y: -6) // small nudge outward
                        }
                    }

                    VStack(spacing: 4) {
                        switch progress {
                        case 0:
                            Text("Let's get started 🚀")
                                .foregroundColor(Color("TextPrimary"))
                                .font(.subheadline)
                            Text("Complete your first habit today")
                                .foregroundColor(Color("TextSecondary"))
                                .font(.caption)

                        case 0..<0.3:
                            Text("Little progress counts 🌱")
                                .foregroundColor(Color("TextPrimary"))
                                .font(.subheadline)
                            Text("Keep the momentum going")
                                .foregroundColor(Color("TextSecondary"))
                                .font(.caption)

                        case 0.3..<0.6:
                            Text("Halfway there ✨")
                                .foregroundColor(Color("TextPrimary"))
                                .font(.subheadline)
                            Text("You're building consistency")
                                .foregroundColor(Color("TextSecondary"))
                                .font(.caption)

                        case 0.6..<0.9:
                            Text("Almost done 💪")
                                .foregroundColor(Color("TextPrimary"))
                                .font(.subheadline)
                            Text("Only \(remaining) more to go")
                                .foregroundColor(Color("TextSecondary"))
                                .font(.caption)

                        case 0.9..<1.0:
                            Text("So close! 🔥")
                                .foregroundColor(Color("TextPrimary"))
                                .font(.subheadline)
                            Text("Just \(remaining) habit left")
                                .foregroundColor(Color("TextSecondary"))
                                .font(.caption)

                        default: // 1.0
                            Text("Great job! 🎉")
                                .foregroundColor(Color("TextPrimary"))
                                .font(.subheadline)
                            Text("You've completed everything")
                                .foregroundColor(Color("TextSecondary"))
                                .font(.caption)
                        }
                    }
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: 180)
            .background(Color("Surface"))
            .cornerRadius(16)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showDetails) {
            HabitsDetailView(initialHabits: habits)
        }
        .accessibilityAddTraits(.isButton)
    }
}

extension Habit {
    static let sampleHabits: [Habit] = {
        let cal = Calendar.current
        let today = Date()
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!
        let threeDaysAgo = cal.date(byAdding: .day, value: -3, to: today)!
        let lastWeek = cal.date(byAdding: .day, value: -7, to: today)!
        let lastMonth = cal.date(byAdding: .month, value: -1, to: today)!

        return [
            Habit(
                id: "h1",
                userId: "u1",
                title: "Hydration",
                description: "Drink at least 2 liters of water daily.",
                frequency: "daily",
                streak: Streak(current: 5, longest: 10, lastCompletedDate: yesterday),
                completions: [
                    Completion(date: today),
                    Completion(date: yesterday),
                    Completion(date: threeDaysAgo)
                ],
                isDeleted: false,
                isAccepted: true,
                createdAt: lastWeek,
                startDate: lastWeek,
                updatedAt: nil,
                endDate: nil,
                reminderTime: "10:00 AM"
            ),
            Habit(
                id: "h2",
                userId: "u1",
                title: "Evening Walk",
                description: "Walk for 20 minutes after dinner.",
                frequency: "daily",
                streak: Streak(current: 2, longest: 6, lastCompletedDate: today),
                completions: [
                    Completion(date: today),
                    Completion(date: yesterday)
                ],
                isDeleted: false,
                isAccepted: true,
                createdAt: lastMonth,
                startDate: lastMonth,
                updatedAt: nil,
                endDate: nil,
                reminderTime: "08:30 PM"
            ),
            Habit(
                id: "h3",
                userId: "u1",
                title: "Weekly Review",
                description: "Review personal goals and progress.",
                frequency: "weekly",
                streak: Streak(current: 0, longest: 3, lastCompletedDate: nil),
                completions: [],
                isDeleted: false,
                isAccepted: false, // still pending
                createdAt: lastWeek,
                startDate: lastWeek,
                updatedAt: nil,
                endDate: nil,
                reminderTime: "Sunday 06:00 PM"
            ),
            Habit(
                id: "h4",
                userId: "u1",
                title: "Journal Writing",
                description: "Write daily reflection before bed.",
                frequency: "daily",
                streak: Streak(current: 1, longest: 4, lastCompletedDate: today),
                completions: [
                    Completion(date: today)
                ],
                isDeleted: false,
                isAccepted: true,
                createdAt: today,
                startDate: today,
                updatedAt: nil,
                endDate: nil,
                reminderTime: "10:00 PM"
            ),
            Habit(
                id: "h5",
                userId: "u1",
                title: "Volunteer Work",
                description: "Spend 2 hours on community service.",
                frequency: "monthly",
                streak: Streak(current: 0, longest: 1, lastCompletedDate: lastMonth),
                completions: [
                    Completion(date: lastMonth)
                ],
                isDeleted: false,
                isAccepted: true,
                createdAt: lastMonth,
                startDate: lastMonth,
                updatedAt: nil,
                endDate: nil,
                reminderTime: nil
            )
        ]
    }()
}
#Preview("With Habits (Today)") {
    VStack {
        HabitCard(
            habits: Habit.sampleHabits,
            selectedDate: Date()              // count completions for today
        )
        .padding()
    }
    .environment(\.colorScheme, .dark)
}

#Preview("Empty Habits") {
    VStack {
        HabitCard(
            habits: [],
            selectedDate: Date()              // date still required
        )
        .padding()
    }
    .environment(\.colorScheme, .dark)
}

#Preview("With Habits (Custom Day)") {
    // Example: pretend we're previewing two days ago
    let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
    return VStack {
        HabitCard(
            habits: Habit.sampleHabits,
            selectedDate: twoDaysAgo          // counts against this day
        )
        .padding()
    }
    .environment(\.colorScheme, .dark)
}

