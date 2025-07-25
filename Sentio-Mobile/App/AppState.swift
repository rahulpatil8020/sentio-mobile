//
//  AppState.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/22/25.
//

import Foundation

final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var isLoggedIn: Bool
    @Published var currentUser: AuthResponse.User?
    

    private init() {
        // ✅ Check if access token exists to set login state
        self.isLoggedIn = TokenManager.shared.accessToken != nil
    }

    // MARK: - Logout Helper
    func logout() {
        TokenManager.shared.clearTokens()
        currentUser = nil
        isLoggedIn = false
    }
}
