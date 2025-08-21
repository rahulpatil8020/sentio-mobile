import SwiftUI

// MARK: - Card (unchanged UI, now feeds real Habit list into the detail screen)
struct HabitCard: View {
    let completed: Int
    let total: Int
    let habits: [Habit] // pass today's/suggested habits

    @State private var showDetails = false

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
                        Text("you’re almost there!")
                            .foregroundColor(Color("TextPrimary"))
                            .font(.subheadline)

                        Text("Only \(remaining) more to go")
                            .foregroundColor(Color("TextSecondary"))
                            .font(.caption)
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


// MARK: - Mock Data for Previews
extension Habit {
    static let sampleHabits: [Habit] = [
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
}

// MARK: - Previews
#Preview {
    VStack {
        HabitCard(
            completed: 1,
            total: 3,
            habits: Habit.sampleHabits
        )
        .padding()
    }
    .environment(\.colorScheme, .dark)
}

#Preview("Habits Fullscreen") {
    HabitsDetailView(initialHabits: Habit.sampleHabits)
        .environment(\.colorScheme, .dark)
}
