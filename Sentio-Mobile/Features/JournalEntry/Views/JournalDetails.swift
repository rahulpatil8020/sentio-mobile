import SwiftUI

struct JournalTranscriptsView: View {
    @Environment(\.dismiss) private var dismiss
    let transcripts: [Transcript]

    private var sorted: [Transcript] {
        transcripts.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        NavigationStack {
            if sorted.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "text.book.closed")
                        .font(.system(size: 42))
                        .foregroundColor(Color("TextSecondary"))
                    Text("No transcripts for this day")
                        .font(.headline)
                        .foregroundColor(Color("TextPrimary"))
                    Text("Your recordings and notes will appear here.")
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("Background").ignoresSafeArea())
                .navigationTitle("Journal")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close") { dismiss() }
                    }
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(sorted) { t in
                            TranscriptRow(transcript: t)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
                .background(Color("Background").ignoresSafeArea())
                .navigationTitle("Journal")
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
}

// MARK: - Row
struct TranscriptRow: View {
    let transcript: Transcript

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: time chip
            HStack(alignment: .center, spacing: 12) {
                Text(timeOnly(transcript.createdAt))
                    .font(.caption2.weight(.bold))
                    .foregroundColor(Color("Primary"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color("Primary").opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                Spacer(minLength: 8)
            }

            // Full text (multi-line, non-clickable)
            Text(transcript.text.isEmpty ? "—" : transcript.text)
                .font(.subheadline)
                .foregroundColor(Color("TextPrimary"))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func timeOnly(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a" // local time, e.g., 3:42 PM
        f.amSymbol = "am"
        f.pmSymbol = "pm"
        f.timeZone = .current
        f.locale = .current
        return f.string(from: date)
    }
}


#Preview("Journal Details – Sample Day") {
    let now = Date()
    let transcripts: [Transcript] = [
        .init(
            id: "t1",
            text: """
Today’s afternoon walk turned into an unexpectedly grounding pause. I noticed the rhythm of footsteps, the sway of trees, and a cool breeze across my face. For a few minutes, thoughts slowed down. I returned home lighter, clearer, and more patient with myself and others. It felt like a reset.
""",
            summary: "Mindful walk reduced mental clutter and restored calm, improving patience and clarity for the rest of the day.",
            createdAt: now.addingTimeInterval(-45 * 60) // 45 mins ago
        ),
        .init(
            id: "t2",
            text: """
Morning standup went smoothly. I shared progress on authentication, unblocked a teammate by clarifying API contracts, and scheduled a short pairing session. It was satisfying to watch the group align quickly. I felt competent and supported, which nudged my motivation upward. Small wins really add up when the team clicks.
""",
            summary: "Clear collaboration and small wins boosted motivation; team alignment remains strong and productive.",
            createdAt: now.addingTimeInterval(-2 * 60 * 60) // 2 hours ago
        ),
        .init(
            id: "t3",
            text: """
Commute was rough. A stalled bus, honking cars, and a persistent drizzle pushed my patience. I breathed through the frustration, reminding myself to loosen the jaw and drop the shoulders. By the time I arrived, the edge had softened. Not perfect, but I redirected the morning before it derailed everything.
""",
            summary: "Stressful commute managed with breathing and posture awareness; avoided a lingering negative mood.",
            createdAt: now.addingTimeInterval(-3 * 60 * 60) // 3 hours ago
        )
    ]

    JournalTranscriptsView(transcripts: transcripts)
        .background(Color("Background"))
        .environment(\.colorScheme, .dark)
}
