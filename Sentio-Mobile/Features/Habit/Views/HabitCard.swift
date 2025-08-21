
import SwiftUI

struct HabitCard: View {
    let completed: Int
    let total: Int

    var progress: Double {
        total == 0 ? 0 : Double(completed) / Double(total)
    }

    var remaining: Int {
        max(0, total - completed)
    }
    
    var progressColor: Color {
        // Hue range: 0.16 (yellow) to 0.33 (green)
        let hue = 0.16 + (0.17 * progress)
        let saturation = 0.9
        let brightness = 0.9 - (0.2 * (1 - progress)) // darker at low progress
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }

    var body: some View {
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
                    .font(.title2)
                    .bold()
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
    }
}

#Preview {
    HabitCard(completed: 3, total: 10)
        .environment(\.colorScheme, .dark)
}
