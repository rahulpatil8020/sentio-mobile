import SwiftUI

struct JournalCard: View {
    let isProcessing: Bool
    let lastEntry: String?   // optional: show last note when not processing

    var body: some View {
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
        .animation(.easeInOut(duration: 0.25), value: isProcessing)
    }
}

#Preview {
    Group {
        // Preview when processing
        JournalCard(isProcessing: true, lastEntry: nil)
            .previewDisplayName("Processing State")
            .padding()
            .background(Color("Background"))

        // Preview with last entry
        JournalCard(isProcessing: false, lastEntry: "I had a really great day today. Felt peaceful.")
            .previewDisplayName("With Last Entry")
            .padding()
            .background(Color("Background"))

        // Preview with no entry
        JournalCard(isProcessing: false, lastEntry: "")
            .previewDisplayName("Empty Entry")
            .padding()
            .background(Color("Background"))
    }
}
