//
//  AuthenticationView.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/25/25.
//

import SwiftUI

// MARK: - Screen Enum
enum AuthScreen {
    case login
    case signup
}


struct AuthenticationView: View {
    @State private var currentScreen: AuthScreen = .signup

    var body: some View {
        ZStack {
            if currentScreen == .login {
                LoginView {
                    withAnimation(.easeInOut) {
                        currentScreen = .signup
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                SignupView {
                    withAnimation(.easeInOut) {
                        currentScreen = .login
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
        }
        .animation(.easeInOut, value: currentScreen)
    }
}

#Preview {
    AuthenticationView()
}
