import SwiftUI

struct CircularNotchedBarShape: Shape {
    var notchFraction: CGFloat = 0.10   // fraction of width for notch radius
    var smoothness: CGFloat = 6         // shoulder curve
    
    func path(in rect: CGRect) -> Path {
        let notchRadius = rect.width * notchFraction
        let notchCenterX = rect.midX
        let notchCenterY: CGFloat = 0
        
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        
        // Left shoulder
        path.addLine(to: CGPoint(x: notchCenterX - notchRadius - smoothness, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: notchCenterX - notchRadius, y: smoothness),
            control: CGPoint(x: notchCenterX - notchRadius, y: 0)
        )
        
        // Notch arc
        path.addArc(
            center: CGPoint(x: notchCenterX, y: notchCenterY),
            radius: notchRadius,
            startAngle: .degrees(168),
            endAngle: .degrees(12),
            clockwise: true
        )
        
        // Right shoulder
        path.addQuadCurve(
            to: CGPoint(x: notchCenterX + notchRadius + smoothness, y: 0),
            control: CGPoint(x: notchCenterX + notchRadius, y: 0)
        )
        
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

struct CustomNavBar: View {
    @Binding var selectedTab: String
    @State private var showRecording = false
    
    var body: some View {
        GeometryReader { geo in
            let barHeight: CGFloat = 70
            let notchRadius = geo.size.width * 0.12
            
            ZStack {
                // Background bar
                CircularNotchedBarShape()
                    .fill(Color("Surface"))
                    .frame(height: barHeight)
                    .elevation(.medium)
                
                // Mic button
                Button(action: { showRecording = true }) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: notchRadius * 0.8))
                        .foregroundColor(Color("TextPrimary"))
                        .padding(notchRadius * 0.4)
                        .background(
                            Circle()
                                .fill(Color("Surface"))
                                .elevation(.high)
                        )
                        .contentShape(Circle())
                }
                .offset(y: -(notchRadius * 0.8))
                .sheet(isPresented: $showRecording) {
                    RecordingModalView(isPresented: $showRecording)
                }
                
                // Side icons
                HStack {
                    Button(action: { selectedTab = "home" }) {
                        Image(systemName: selectedTab == "home" ? "house.fill" : "house")
                            .font(.system(size: 28))
                            .foregroundColor(Color("TextPrimary").opacity(0.9))
                    }
                    
                    Spacer()
                    
                    Button(action: { selectedTab = "notifications" }) {
                        Image(systemName: selectedTab == "notifications" ? "bell.fill" : "bell")
                            .font(.system(size: 28))
                            .foregroundColor(Color("TextPrimary").opacity(0.9))
                    }
                }
                .padding(.horizontal, geo.size.width * 0.18)
                .padding(.bottom, geo.safeAreaInsets.bottom == 0 ? 10 : geo.safeAreaInsets.bottom)
            }
            .frame(width: geo.size.width, height: barHeight)
        }
        .frame(height: 70)
    }
}

#Preview {
    VStack {
        Spacer()
        CustomNavBar(selectedTab: .constant("home"))
    }
    .background(Color("Background"))
    .ignoresSafeArea()
    .preferredColorScheme(.light)   // 👈 switch between .light / .dark
}
