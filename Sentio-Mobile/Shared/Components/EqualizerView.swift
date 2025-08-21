import SwiftUI

struct EqualizerView: View {
    @State private var phases: [CGFloat] = [0.2, 0.5, 0.35, 0.65, 0.4]
    private let timer = Timer.publish(every: 0.18, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<phases.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color("Primary"))
                    .frame(width: 6, height: max(10, 50 * phases[i]))
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.18)) {
                phases = phases.map { _ in .random(in: 0.2...0.5) }
            }
        }
    }
}

#Preview {
    EqualizerView()
        .padding()
        .background(Color("Background")) // Optional, use to see contrast
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Equalizer Animation")
}

#Preview {
    EqualizerView()
        .padding()
        .background(Color("Background"))
        .environment(\.colorScheme, .dark)
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Equalizer – Dark Mode")
}
