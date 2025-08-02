//
//  SecureInputField.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/29/25.
//

import SwiftUI

struct SecureInputField: View {
    let placeholder: String
    @Binding var text: String
    let systemImage: String
    
    @State private var isSecure: Bool = true  // Tracks whether the field is secure or visible
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(Color("TextSecondary"))
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .autocapitalization(.none)
                    .foregroundColor(Color("TextPrimary"))
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .autocapitalization(.none)
                    .foregroundColor(Color("TextPrimary"))
            }
            
            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(Color("TextSecondary"))
            }
        }
        .padding()
        .background(Color("SurfaceSecondary"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("TextSecondary").opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        SecureInputField(
            placeholder: "Password",
            text: .constant(""),
            systemImage: "lock.fill"
        )
        
        SecureInputField(
            placeholder: "Confirm Password",
            text: .constant("123456"),
            systemImage: "lock.fill"
        )
    }
    .padding()
    .background(Color("Background").ignoresSafeArea())
    .environment(\.colorScheme, .dark)   // 🔹 Toggle this between .light / .dark
}
