import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    func login() async {
        isLoading = true
        errorMessage = nil

        let payload = ["email": email, "password": password]

        do {
            let data = try JSONEncoder().encode(payload)
            let response: AuthResponse = try await APIClient.shared.request(
                endpoint: "/auth/login",
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
