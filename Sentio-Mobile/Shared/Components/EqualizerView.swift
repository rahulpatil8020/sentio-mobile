import SwiftUI

struct EqualizerView: View {
    @State private var phases: [CGFloat] = [0.2, 0.5, 0.35, 0.75, 0.4]
    private let timer = Timer.publish(every: 0.18, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<phases.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color("Primary"))
                    .frame(width: 6, height: max(10, 50 * phases[i]))
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.18)) {
                phases = phases.map { _ in .random(in: 0.2...0.9) }
            }
        }
    }
}
