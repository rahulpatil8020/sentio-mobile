
import SwiftUI

struct EmotionStatesDetailView: View {
    @Environment(\.dismiss) private var dismiss   // ✅ enable closing

    let emotionalStates: [EmotionalState]
    let emotionLevelMap: [String: Int]
    let emotionColor: (EmotionalState) -> Color
    let emojiOrSymbol: (String) -> String

    private func formattedTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"   // keep minutes for detail list
        f.amSymbol = "am"
        f.pmSymbol = "pm"
        f.timeZone = .current
        f.locale = .current
        return f.string(from: date)
    }

    var body: some View {
        let sortedDesc = emotionalStates.sorted { $0.createdAt > $1.createdAt }
        let latest = sortedDesc.first

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Header with latest (if exists)
                    if let latest {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Text(emojiOrSymbol(latest.state)).font(.system(size: 32))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(latest.state.capitalized)
                                        .font(.title3.bold())
                                        .foregroundColor(Color("TextPrimary"))
                                    Text(formattedTime(latest.createdAt))
                                        .font(.caption)
                                        .foregroundColor(Color("TextSecondary"))
                                }
                                Spacer()
                                Text("Intensity \(latest.intensity)/10")
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(emotionColor(latest))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(emotionColor(latest).opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                            if let note = latest.note, !note.isEmpty {
                                Text("“\(note)”")
                                    .font(.callout.italic())
                                    .foregroundColor(Color("TextSecondary"))
                            }
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    // List (latest-first) EXCLUDING the latest to avoid duplicates
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(sortedDesc.filter { $0.id != latest?.id }) { state in
                            EmotionStateRow(
                                state: state,
                                color: emotionColor(state),
                                emoji: emojiOrSymbol(state.state),
                                timeText: formattedTime(state.createdAt)
                            )
                        }
                    }
                }
                .padding(16)
            }
            .background(Color("Background").ignoresSafeArea())
            .navigationTitle("Emotional Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }   // ✅ actually closes now
                }
            }
        }
        .background(Color("Background").ignoresSafeArea())
    }
}

// MARK: - Row for a single emotional state
struct EmotionStateRow: View {
    let state: EmotionalState
    let color: Color
    let emoji: String
    let timeText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                Text(emoji)
                    .font(.system(size: 28))
                VStack(alignment: .leading, spacing: 2) {
                    Text(state.state.capitalized)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color("TextPrimary"))
                    Text(timeText)
                        .font(.caption)
                        .foregroundColor(Color("TextSecondary"))
                }
                Spacer()
                // Intensity chip
                Text("Intensity \(state.intensity)/10")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            if let note = state.note, !note.isEmpty {
                Text("“\(note)”")
                    .font(.callout.italic())
                    .foregroundColor(Color("TextSecondary"))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}



#Preview("Emotion Details") {
    let sample: [EmotionalState] = [
        .init(id: "1", state: "Angry", intensity: 8, note: "Traffic Is really bad these days and I am tired all the time. It's so frustrating to come home after work.", createdAt: Date().addingTimeInterval(-3600 * 6)),
        .init(id: "2", state: "Sad", intensity: 4, note: nil, createdAt: Date().addingTimeInterval(-3600 * 5)),
        .init(id: "3", state: "Calm", intensity: 6, note: "Breathing helped", createdAt: Date().addingTimeInterval(-3600 * 4)),
        .init(id: "4", state: "Happy", intensity: 9, note: "Got a compliment", createdAt: Date().addingTimeInterval(-3600 * 2)),
    ]
    EmotionStatesDetailView(
        emotionalStates: sample,
        emotionLevelMap: [
            "angry": 0, "apathetic": 1, "depressed": 2, "sad": 3,
            "frustrated": 4, "overwhelmed": 5, "anxious": 6,
            "stressed": 7, "tired": 8, "neutral": 9,
            "productive": 10, "content": 11, "calm": 12,
            "relaxed": 13, "excited": 14, "happy": 15, "joyful": 15
        ],
        emotionColor: { _ in .teal },
        emojiOrSymbol: { _ in "🙂" }
    )
    .environment(\.colorScheme, .dark)
}
