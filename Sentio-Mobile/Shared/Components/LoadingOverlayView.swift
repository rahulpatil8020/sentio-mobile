import SwiftUI

struct LoadingOverlayView: View {
    @State private var animate = false
    
    /// Optional bottom padding (default = 0)
    var bottomPadding: CGFloat = 0

    // Tweak these to taste
    private let size: CGFloat = 25
    private let spacing: CGFloat = 14
    private let duration: Double = 0.7
    private let stagger: Double = 0.15
    private let corner: CGFloat = 4

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()

            VStack {
                HStack(spacing: spacing) {
                    ForEach(0..<4) { i in
                        RoundedRectangle(cornerRadius: corner, style: .continuous)
                            .fill(Color("Primary"))
                            .frame(width: size, height: size)
                            .rotation3DEffect(
                                .degrees(animate ? 180 : 0),
                                axis: (x: 1, y: 1, z: 1),
                                perspective: 0.6
                            )
                            .opacity(animate ? 1 : 0.9)
                            .animation(
                                .easeInOut(duration: duration)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(i) * stagger),
                                value: animate
                            )
                    }
                }
                .padding(.bottom, bottomPadding)
            }
        }
        .onAppear { animate = true }
    }
}

#Preview("Loading Overlay Default") {
    LoadingOverlayView()
        .environment(\.colorScheme, .dark)
}

#Preview("Loading Overlay With Bottom Padding") {
    LoadingOverlayView(bottomPadding: 80)
        .environment(\.colorScheme, .dark)
}
