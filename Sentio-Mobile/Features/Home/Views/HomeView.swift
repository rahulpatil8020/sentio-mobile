import SwiftUI

struct HomeView: View {
    @ObservedObject private var appState = AppState.shared
    @StateObject private var viewModel = HomeViewModel.shared

    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // 1. Header
                    if let user = appState.currentUser {
                        HeaderView(user: user, selectedDate: appState.selectedDate)
                    }
                    
                    // 2. Date Selector
                    DateSelectorView(selectedDate: $appState.selectedDate)
                    
                    // 3. Journal Card (reactive)
                    JournalCard(
                        isProcessing: appState.isProcessingTranscript,
                        lastEntry: appState.lastJournalSnippet // <- optional string you populate
                    )
                    
                    // 4. Habit + Emotion Row
                    HStack(spacing: 16) {
                        Rectangle()
                            .fill(Color("Surface"))
                            .frame(height: 120)
                            .cornerRadius(12)
                            .overlay(
                                Text("Habit Card")
                                    .foregroundColor(Color("TextSecondary"))
                            )
                        
                        Rectangle()
                            .fill(Color("Surface"))
                            .frame(height: 120)
                            .cornerRadius(12)
                            .overlay(
                                Text("Emotion Card")
                                    .foregroundColor(Color("TextSecondary"))
                            )
                    }
                    
                    // 5. Task List
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Task List")
                                .font(.headline)
                                .foregroundColor(Color("TextPrimary"))
                            Spacer()
                            Circle()
                                .fill(Color("SurfaceSecondary"))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Text("+")
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                )
                        }
                        
                        Rectangle()
                            .fill(Color("Surface"))
                            .frame(height: 150)
                            .cornerRadius(12)
                            .overlay(
                                Text("Task List Placeholder")
                                    .foregroundColor(Color("TextSecondary"))
                            )
                    }
                }
                .padding(.horizontal)
            }
        .onAppear {
            Task {
                await viewModel.loadTodayIfNeeded()
            }
        }
        .background(Color("Background").ignoresSafeArea())
    }
}
#Preview {
    struct HomeViewPreview: View {
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
            HomeView()
                .environment(\.colorScheme, .dark) // 👈 Preview in dark mode
        }
    }
    
    return HomeViewPreview()
}
