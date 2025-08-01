import SwiftUI

// 🔹 Custom shape with a circular notch in the middle
struct CircularNotchedBarShape: Shape {
    var notchRadius: CGFloat = 50       // radius of the circular cutout
    var smoothness: CGFloat = 12        // shoulder roundness (1 param, both sides)
    
    func path(in rect: CGRect) -> Path {
        let notchCenterX = rect.midX
        let notchCenterY: CGFloat = 0   // top edge of the bar
        
        var path = Path()
        
        // Start at bottom-left
        path.move(to: CGPoint(x: 0, y: 0))
        
        // Left straight edge → shoulder start
        path.addLine(to: CGPoint(x: notchCenterX - notchRadius - smoothness, y: 0))
        
        // Left shoulder curve
        path.addQuadCurve(
            to: CGPoint(x: notchCenterX - notchRadius, y: smoothness),
            control: CGPoint(x: notchCenterX - notchRadius, y: 0)
        )
        
        // Arc (notch cutout)
        path.addArc(
            center: CGPoint(x: notchCenterX, y: notchCenterY),
            radius: notchRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(15),
            clockwise: true
        )
        
        // Right shoulder curve (mirror of left)
        path.addQuadCurve(
            to: CGPoint(x: notchCenterX + notchRadius + smoothness, y: 0),
            control: CGPoint(x: notchCenterX + notchRadius, y: 0)
        )
        
        // Continue flat → right edge
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        
        // Close rest of bar
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

struct CustomNavBar: View {
    @Binding var selectedTab: String
    @State private var showRecording = false   // 🔹 controls modal
    
    var body: some View {
        ZStack {
            CircularNotchedBarShape()
                .fill(Color("backgroundColor"))
                .frame(height: 70)
                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: -2)
            
            // 🔹 Mic button in notch
            Button(action: {
                showRecording = true   // open modal
            }) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .padding(28)
                    .background(
                        Circle()
                            .fill(Color.black)
                            .shadow(color: .black.opacity(0.8), radius: 20, x: 0, y: 10)
                    )
            }
            .offset(y: -35)
            .sheet(isPresented: $showRecording) {
                RecordingModalView(isPresented: $showRecording) // 🔹 your modal
            }
            
            // 🔹 Side icons
            HStack {
                Button(action: { selectedTab = "home" }) {
                    Image(systemName: selectedTab == "home" ? "house.fill" : "house")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Button(action: { selectedTab = "notifications" }) {
                    Image(systemName: selectedTab == "notifications" ? "bell.fill" : "bell")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(.horizontal, 60)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: 70)
    }
}

#Preview {
    VStack {
        Spacer()
        CustomNavBar(selectedTab: .constant("home"))
    }
    .background(Color.gray.opacity(0.2))
    .ignoresSafeArea()
}
