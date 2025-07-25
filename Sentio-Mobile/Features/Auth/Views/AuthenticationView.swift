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
    @State private var isLogin = false

    var body: some View {
        VStack {
            if isLogin {
                LoginView {
                    withAnimation(.easeInOut) {
                        isLogin.toggle()
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                SignupView {
                    withAnimation(.easeInOut) {
                        isLogin.toggle()
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
            }
        }
        .animation(.easeInOut, value: isLogin)
    }
}

#Preview{
    AuthenticationView()
}
