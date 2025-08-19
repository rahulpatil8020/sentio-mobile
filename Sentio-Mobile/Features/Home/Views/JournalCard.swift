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
                        .frame(width: 56, height: 56)

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
                .padding()
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
                            .lineLimit(2)
                    }

                    Spacer()
                }
                .padding()
            }
        }
        .frame(height: 80)
        .animation(.easeInOut(duration: 0.25), value: isProcessing)
    }
}
