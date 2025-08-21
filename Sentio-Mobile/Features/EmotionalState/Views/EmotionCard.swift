import SwiftUI

import SwiftUI

struct EmotionGraphCard: View {
    let emotionalStates: [EmotionalState]

    @State private var showDetails = false

    private let emotionLevelMap: [String: Int] = [
        "angry": 0, "apathetic": 1, "depressed": 2, "sad": 3,
        "frustrated": 4, "overwhelmed": 5, "anxious": 6,
        "stressed": 7, "tired": 8, "neutral": 9,
        "productive": 10, "content": 11, "calm": 12,
        "relaxed": 13, "excited": 14, "happy": 15, "joyful": 15
    ]

    var latestEmotion: EmotionalState? {
        emotionalStates.sorted { $0.createdAt > $1.createdAt }.first
    }

    var body: some View {
        Button {
            if !emotionalStates.isEmpty { showDetails = true }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                if let latest = latestEmotion {
                    VStack(alignment: .leading){
                        Text("Emotional Insight")
                            .font(.headline)
                            .foregroundColor(Color("TextPrimary"))
                        if emotionalStates.count != 1 {
                            Text(latest.state.capitalized)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(Color("TextPrimary"))
                        }
                    }
                }

                GeometryReader { geo in
                    if emotionalStates.isEmpty {
                        Text("No emotions today.")
                            .frame(width: geo.size.width, height: geo.size.height)
                            .foregroundColor(Color("TextSecondary"))
                            .background(Color("Surface"))
                            .cornerRadius(12)
                            .transition(.opacity)
                    } else if emotionalStates.count == 1, let state = emotionalStates.first {
                        // Single-state summary
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                Text(emojiOrSymbol(for: state.state))
                                    .font(.system(size: 32))
                                Text(state.state.capitalized)
                                    .font(.title2.bold())
                                    .foregroundColor(Color("TextPrimary"))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Intensity")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                ProgressView(value: Double(state.intensity), total: 10)
                                    .tint(emotionColor(for: state))
                            }

                            if let note = state.note, !note.isEmpty {
                                Text("“\(note)”")
                                    .font(.body.italic())
                                    .foregroundColor(Color("TextSecondary"))
                            }
                            Spacer()
                        }
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                        .background(Color("Surface"))
                        .cornerRadius(12)
                        .transition(.opacity)
                    } else {
                        // Graph
                        let sorted = emotionalStates.sorted(by: { $0.createdAt < $1.createdAt })
                        let widthPerPoint = geo.size.width / CGFloat(max(sorted.count, 2))
                        let totalWidth = CGFloat(sorted.count - 1) * widthPerPoint
                        let xOffset = (geo.size.width - totalWidth) / 2
                        let padding: CGFloat = 20
                        let latest = latestEmotion

                        ZStack {
                            // Lines
                            ForEach(0..<sorted.count - 1, id: \.self) { i in
                                let current = sorted[i]
                                let next = sorted[i + 1]

                                let x1 = xOffset + CGFloat(i) * widthPerPoint
                                let x2 = xOffset + CGFloat(i + 1) * widthPerPoint
                                let y1 = yPosition(for: current, height: geo.size.height, padding: padding)
                                let y2 = yPosition(for: next, height: geo.size.height, padding: padding)

                                Path { path in
                                    path.move(to: CGPoint(x: x1, y: y1))
                                    path.addLine(to: CGPoint(x: x2, y: y2))
                                }
                                .stroke(LinearGradient(
                                    gradient: Gradient(colors: [
                                        emotionColor(for: current),
                                        emotionColor(for: next)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ), lineWidth: 3)
                            }

                            // Dots + ring for latest
                            ForEach(0..<sorted.count, id: \.self) { i in
                                let state = sorted[i]
                                let x = xOffset + CGFloat(i) * widthPerPoint
                                let y = yPosition(for: state, height: geo.size.height, padding: padding)

                                if state.id == latest?.id {
                                    Circle()
                                        .stroke(emotionColor(for: state), lineWidth: 3)
                                        .frame(width: 18, height: 18)
                                        .position(x: x, y: y)
                                }

                                Circle()
                                    .fill(emotionColor(for: state))
                                    .frame(width: 10, height: 10)
                                    .position(x: x, y: y)
                            }

                            // Time labels – hour only (e.g., 3 pm)
                            ForEach(0..<sorted.count, id: \.self) { i in
                                let state = sorted[i]
                                let x = xOffset + CGFloat(i) * widthPerPoint
                                let time = formattedHour(state.createdAt)
                                Text(time)
                                    .font(.caption2)
                                    .foregroundColor(Color("TextSecondary"))
                                    .position(x: x, y: geo.size.height - 8)
                            }
                        }
                        .transition(.opacity)
                    }
                }
                .frame(height: 110)
                .animation(.easeInOut(duration: 0.3), value: emotionalStates.count)
            }
            .padding(10)
            .frame(maxWidth: .infinity, maxHeight: 180)
            .background(Color("Surface"))
            .cornerRadius(16)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showDetails) {
            EmotionStatesDetailView(
                emotionalStates: emotionalStates,
                emotionLevelMap: emotionLevelMap,
                emotionColor: emotionColor(for:),
                emojiOrSymbol: emojiOrSymbol(for:)
            )
        }
    }

    // MARK: - Helpers

    private func yPosition(for state: EmotionalState, height: CGFloat, padding: CGFloat) -> CGFloat {
        let level = emotionLevelMap[state.state.lowercased()] ?? 8
        let normalized = CGFloat(level) / 15.0
        return (1.0 - normalized) * (height - 2 * padding) + padding
    }

    // ⬇️ Hour-only for graph labels
    private func formattedHour(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h a"   // e.g., 3 PM
        f.amSymbol = "am"
        f.pmSymbol = "pm"
        f.timeZone = .current
        f.locale = .current
        return f.string(from: date)
    }

    private func emotionColor(for state: EmotionalState) -> Color {
        let base: Color
        switch state.state.lowercased() {
        case "happy", "joyful": base = .green
        case "excited": base = .yellow
        case "calm", "relaxed": base = .mint
        case "content", "productive": base = .teal
        case "neutral": base = .gray
        case "tired": base = .brown
        case "stressed", "anxious", "overwhelmed": base = .orange
        case "sad", "depressed", "apathetic": base = .blue
        case "frustrated": base = .pink
        case "angry": base = .red
        default: base = .gray
        }
        return base.opacity(Double(state.intensity) / 10.0)
    }

    private func emojiOrSymbol(for state: String) -> String {
        switch state.lowercased() {
        case "happy", "joyful": return "😄"
        case "excited": return "🤩"
        case "calm", "relaxed": return "😌"
        case "content": return "🙂"
        case "productive": return "💪"
        case "neutral": return "😐"
        case "tired": return "😴"
        case "stressed": return "😫"
        case "anxious": return "😟"
        case "overwhelmed": return "😵"
        case "frustrated": return "😤"
        case "sad": return "😢"
        case "depressed": return "😞"
        case "apathetic": return "🥱"
        case "angry": return "😠"
        default: return "🧠"
        }
    }
}

