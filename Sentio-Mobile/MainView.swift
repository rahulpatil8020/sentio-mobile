import SwiftUI

struct MainView: View {
    @State private var selectedTab: String = "home"
    
    @ObservedObject private var appState = AppState.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case "home":
                    HomeView()
                case "notifications":
                    NotificationsView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Background").ignoresSafeArea())

            if appState.isHomeLoadingFirstTime {
                LoadingOverlayView()
                    .transition(.opacity)
                    .zIndex(1)
            }

            VStack {
                Spacer()
                CustomNavBar(selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    struct MainViewPreview: View {
        init() {
            // Inject a mock user into AppState for preview
            AppState.shared.currentUser = User(
                id: "123",
                name: "Rahul Patil",
                email: "rahul@example.com",
                createdAt: "2025-08-02T12:00:00Z",
                isOnboarded: true,
                city: "San Francisco",
                country: "USA",
                profession: "Software Engineer",
                goals: ["Personal growth", "Fitness"]
            )
        }
        
        var body: some View {
            MainView()
                .environment(\.colorScheme, .dark) // 👈 Dark mode
        }
    }
    
    return MainViewPreview()
}
