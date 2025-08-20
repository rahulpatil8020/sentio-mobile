import SwiftUI

struct LoadingOverlayView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(Color("Primary").opacity(0.3), lineWidth: 4)
                        .frame(width: 60, height: 60)

                    Circle()
                        .fill(Color("Primary"))
                        .frame(width: 20, height: 20)
                        .scaleEffect(isAnimating ? 1.4 : 1)
                        .opacity(isAnimating ? 0.3 : 1)
                        .animation(
                            .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }

                Text("Sentio")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color("Primary"))
                    .opacity(isAnimating ? 1 : 0.5)
                    .animation(
                        .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct LoadingOverlayPreviewWrapper: View {
    @State private var animate = false

    var body: some View {
        LoadingOverlayView()
            .onAppear {
                animate = true
            }
    }
}

#Preview {
    LoadingOverlayPreviewWrapper()
        .environment(\.colorScheme, .dark)
}
