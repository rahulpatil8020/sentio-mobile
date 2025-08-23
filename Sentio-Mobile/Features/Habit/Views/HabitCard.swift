import SwiftUI

// MARK: - Card
struct HabitCard: View {
    let habits: [Habit]          // already filtered for isDeleted outside, ideally
    let selectedDate: Date       // 👈 pass this in

    @State private var showDetails = false

    // MARK: - Derived values
    private var total: Int { habits.count }

    private var completed: Int {
        let cal = Calendar.current
        // Count a habit as completed if any completion is on selectedDate,
        // OR the streak.lastCompletedDate is on selectedDate (defensive).
        return habits.filter { h in
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

                if habits.isEmpty {
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

                    VStack(spacing: 4) {
                        if progress >= 1.0 {
                            Text("Great job! 🎉")
                                .foregroundColor(Color("TextPrimary"))
                                .font(.subheadline)
                        } else {
                            Text("You’re almost there!")
                                .foregroundColor(Color("TextPrimary"))
                                .font(.subheadline)

                            Text("Only \(remaining) more to go")
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
        let twoDaysAgo = cal.date(byAdding: .day, value: -2, to: today)!

        return [
            Habit(
                id: "h1",
                title: "Morning Run",
                description: "Run at least 2 km outside or on treadmill.",
                createdAt: twoDaysAgo,
                updatedAt: nil,
                startDate: twoDaysAgo,
                endDate: nil,
                frequency: "daily",
                reminderTime: "07:00 AM",
                streak: Streak(current: 3, longest: 7, lastCompletedDate: yesterday),
                completions: [
                    Completion(date: today),
                    Completion(date: yesterday),
                    Completion(date: twoDaysAgo)
                ],
                isDeleted: false,
                isAccepted: true
            ),
            Habit(
                id: "h2",
                title: "Read Book",
                description: "Read at least 20 pages of non-fiction.",
                createdAt: yesterday,
                updatedAt: nil,
                startDate: yesterday,
                endDate: nil,
                frequency: "daily",
                reminderTime: "09:00 PM",
                streak: Streak(current: 1, longest: 4, lastCompletedDate: today),
                completions: [
                    Completion(date: today)
                ],
                isDeleted: false,
                isAccepted: true
            ),
            Habit(
                id: "h3",
                title: "Meditation",
                description: "10 minutes mindfulness meditation.",
                createdAt: today,
                updatedAt: nil,
                startDate: today,
                endDate: nil,
                frequency: "weekly",
                reminderTime: nil,
                streak: Streak(current: 0, longest: 2, lastCompletedDate: nil),
                completions: [],
                isDeleted: false,
                isAccepted: false // pending
            ),
            Habit(
                id: "h4",
                title: "Stretching Routine",
                description: "5–10 minutes evening mobility/stretching.",
                createdAt: twoDaysAgo,
                updatedAt: nil,
                startDate: twoDaysAgo,
                endDate: nil,
                frequency: "monthly",
                reminderTime: "08:00 PM",
                streak: Streak(current: 2, longest: 5, lastCompletedDate: twoDaysAgo),
                completions: [
                    Completion(date: twoDaysAgo)
                ],
                isDeleted: false,
                isAccepted: true
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

#Preview("Habits Fullscreen") {
    HabitsDetailView(initialHabits: Habit.sampleHabits)
        .environment(\.colorScheme, .dark)
}
