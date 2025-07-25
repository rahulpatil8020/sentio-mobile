import Foundation

@MainActor
final class SignupViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var showOnboarding = false

    // MARK: - Field Validation
    var isFormPartiallyValid: Bool {
        name.trimmingCharacters(in: .whitespaces).count >= 2 &&
        email.contains("@") &&
        password.count >= 6 &&
        confirmPassword.count >= 6
    }

    // MARK: - Signup Action
    func signup() async {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        isLoading = true
        errorMessage = nil

        let payload = [
            "name": trimmedName,
            "email": trimmedEmail,
            "password": password
        ]

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

            showOnboarding = true

        } catch let serverError as ServerErrorResponse {
            errorMessage = serverError.error.message
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
