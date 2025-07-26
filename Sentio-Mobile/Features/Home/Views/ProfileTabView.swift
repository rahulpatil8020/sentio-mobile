import SwiftUI

struct ProfileTabView: View {
    @ObservedObject var vm: HomeViewModel
    @State private var showLogoutConfirmation = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    DashboardCardView(
                        title: "User Info",
                        color: .blue,
                        icon: "person.fill"
                    ) {
                        Text("Email: \(vm.user?.email ?? "N/A")")
                        Text("User ID: \(vm.user?.id ?? "N/A")")
                    }

                    DashboardCardView(
                        title: "Past Emotional States",
                        color: .orange,
                        icon: "face.smiling.fill"
                    ) {
                        ForEach(vm.pastEmotions) { emotion in
                            VStack(alignment: .leading) {
                                Text("\(emotion.state) - \(emotion.intensity)/10")
                                    .font(.headline)
                                Text(emotion.note)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .alert("Are you sure you want to log out?", isPresented: $showLogoutConfirmation) {
                Button("Log Out", role: .destructive) {
                    vm.logout()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}
