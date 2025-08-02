import SwiftUI

struct HomeView: View {
    @ObservedObject private var appState = AppState.shared
    
    var unreadCount: Int = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Profile Avatar
            HStack {
                ZStack {
                    // Background circle
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    
                    // Profile symbol
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                }
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3) // border
                )
            }
            
            // 🚪 Logout Button
            Button(action: {
                appState.logout() // 👈 directly call your existing logout
            }) {
                Text("Logout")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                    .shadow(color: .red.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    HomeView()
}
