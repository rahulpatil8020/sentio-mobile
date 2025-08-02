//
//  UserService.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 8/2/25.
//

import Foundation

@MainActor
final class UserService {
    static let shared = UserService()
    private init() {}

    func refreshUser() async {
        guard AppState.shared.isLoggedIn else { return }
        do {
            let response: User = try await APIClient.shared.request(
                endpoint: "/user/me",
                method: "GET",
                requiresAuth: true
            )
            AppState.shared.setUser(response)
        } catch APIError.unauthorized {
            AppState.shared.logout()
        } catch {
            if let cached = UserManager.shared.loadUser() {
                AppState.shared.setUser(cached)
            } else {
                AppState.shared.logout()
            }
        }
    }
}
