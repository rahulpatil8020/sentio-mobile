import SwiftUI


// MARK: - Card
struct JournalCard: View {
    let isProcessing: Bool
    let lastEntry: String?
    let transcripts: [Transcript] = [] // optional; defaults to empty

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


// MARK: - Previews

#Preview("Processing State") {
    JournalCard(isProcessing: true, lastEntry: nil)
        .padding()
        .background(Color("Background"))
        .environment(\.colorScheme, .dark)
}

#Preview("With Last Entry") {
    JournalCard(isProcessing: false, lastEntry: "I had a really great day today. Felt peaceful.")
        .padding()
        .background(Color("Background"))
        .environment(\.colorScheme, .dark)
}

#Preview("Empty Entry") {
    JournalCard(isProcessing: false, lastEntry: "")
        .padding()
        .background(Color("Background"))
        .environment(\.colorScheme, .dark)
}

