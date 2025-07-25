import Foundation

@MainActor
final class SignupViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage: String?
    @Published var isLoading = false

    @Published var showOnboarding = false  // ✅ New

    func signup() async {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        isLoading = true
        errorMessage = nil

        let payload = ["email": email, "password": password]

        do {
            let data = try JSONEncoder().encode(payload)
            let response: AuthResponse = try await APIClient.shared.request(
                endpoint: "/signup",
                method: "POST",
                body: data
            )

            TokenManager.shared.accessToken = response.data.accessToken
            TokenManager.shared.refreshToken = response.data.refreshToken
            AppState.shared.currentUser = response.data.user
            AppState.shared.isLoggedIn = true

            showOnboarding = true  // ✅ Trigger onboarding screen

        } catch let serverError as ServerErrorResponse {
            errorMessage = serverError.error.message
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
