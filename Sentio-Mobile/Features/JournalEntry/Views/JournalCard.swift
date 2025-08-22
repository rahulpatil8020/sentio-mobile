import SwiftUI


// MARK: - Card
struct JournalCard: View {
    let isProcessing: Bool
    let lastEntry: String?
    let transcripts: [Transcript] // optional; defaults to empty

    @State private var showAllTranscripts = false

    var body: some View {
        Button {
            guard !isProcessing else { return }
            showAllTranscripts = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("Surface"))

                if isProcessing {
                    HStack(spacing: 16) {
                        EqualizerView()
                            .frame(width: 40, height: 40)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Processing your transcript…")
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))

                            Text("This usually takes a few seconds.")
                                .font(.subheadline)
                                .foregroundColor(Color("TextSecondary"))
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    HStack(spacing: 12) {
                        Image(systemName: "book.pages.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color("Primary"))
                            .padding(12)
                            .background(Circle().fill(Color("SurfaceSecondary").opacity(0.3)))

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Journal")
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))

                            Text((lastEntry?.isEmpty == false ? lastEntry! : "No entry yet. Tap mic to add one."))
                                .font(.subheadline)
                                .foregroundColor(Color("TextSecondary"))
                                .lineLimit(1)
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .frame(height: 66)
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: isProcessing)
        .disabled(isProcessing)
        .fullScreenCover(isPresented: $showAllTranscripts) {
            JournalTranscriptsView(transcripts: transcripts)
        }
    }
}


#Preview("With Transcripts") {
    let now = Date()
    let transcripts: [Transcript] = [
        .init(id: "t1",
              text: "This morning I walked quietly around the park, noticing the sound of leaves and the rhythm of my steps. It gave me a rare sense of calm before starting work.",
              summary: "Morning walk brought calm",
              createdAt: now.addingTimeInterval(-60*60)),
        .init(id: "t2",
              text: "Team standup went smoothly. Shared progress on auth bug fix and clarified blockers for others. It felt good to support the team while also moving my own tasks forward.",
              summary: "Supportive team standup",
              createdAt: now.addingTimeInterval(-2*60*60)),
        .init(id: "t3",
              text: "The evening traffic jam was draining. I tried to focus on breathing and listening to music, but the frustration lingered. Still, I managed to shift my mood once home.",
              summary: "Commute stress managed",
              createdAt: now.addingTimeInterval(-3*60*60))
    ]

    return JournalCard(
        isProcessing: false,
        lastEntry: transcripts.first?.text,
        transcripts: transcripts
    )
    .padding()
    .background(Color("Background"))
    .environment(\.colorScheme, .dark)
}
