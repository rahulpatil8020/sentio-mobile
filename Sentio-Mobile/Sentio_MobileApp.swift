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

    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                HomeTabView()
            } else {
                // Replace NavigationView + LoginView with AuthenticationView
                AuthenticationView()
            }
        }
    }
}
