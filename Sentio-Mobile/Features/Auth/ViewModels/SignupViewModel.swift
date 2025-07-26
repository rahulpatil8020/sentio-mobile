import Foundation

@MainActor
final class SignupViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var errorMessage: String?
    @Published var isLoading = false

    // MARK: - Email Validation
    var isValidEmail: Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailFormat).evaluate(with: email)
    }

    // MARK: - Field Validation
    var isFormPartiallyValid: Bool {
        name.trimmingCharacters(in: .whitespaces).count >= 2 &&
        email.count > 3 &&
        password.count >= 6 &&
        confirmPassword.count >= 6
    }

    // MARK: - Signup Action
    func signup() async {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)

        guard isValidEmail else {
            errorMessage = "Please enter a valid email address"
            return
        }

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
                endpoint: "/auth/signup",
                method: "POST",
                body: data
            )

            TokenManager.shared.accessToken = response.data.accessToken
            TokenManager.shared.refreshToken = response.data.refreshToken
            AppState.shared.currentUser = response.data.user
            AppState.shared.isLoggedIn = true

        } catch let serverError as ServerErrorResponse {
            errorMessage = serverError.error.message
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
