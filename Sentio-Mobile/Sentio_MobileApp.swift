//
//  Sentio_MobileApp.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/22/25.
//

import SwiftUI

@main
struct Sentio_MobileApp: App {
    @StateObject private var appState = AppState.shared
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "TextPrimary")!]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "TextPrimary")!]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                if let user = appState.currentUser {
                    if user.isOnboarded {
                        MainView()
                    } else {
                        OnboardingView()
                    }
                } else {
                    // Fallback to login if for some reason user data is missing
                    AuthenticationView()
                }
            } else {
                AuthenticationView()
            }
        }
    }
}
