//
//  InputField.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/29/25.
//

import SwiftUI

struct InputField: View {
    let placeholder: String
    @Binding var text: String
    let systemImage: String
    var characterLimit: Int? = nil

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(Color("TextSecondary"))
                
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .autocapitalization(.none)
                    .foregroundColor(Color("TextPrimary"))
            }
            .padding()
            .background(Color("SurfaceSecondary"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("TextSecondary").opacity(0.3), lineWidth: 1)
            )

            if let limit = characterLimit {
                Text("\(text.count)/\(limit)")
                    .font(.caption2)
                    .foregroundColor(text.count > limit ? .orange : Color("TextSecondary"))
                    .padding(.top, 6)
                    .padding(.trailing, 12)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        InputField(
            placeholder: "Enter your name",
            text: .constant("Rahul"),
            systemImage: "person.fill"
        )

        InputField(
            placeholder: "Enter your profession",
            text: .constant("Developer"),
            systemImage: "briefcase.fill",
            characterLimit: 15
        )
    }
    .padding()
    .background(Color("Background").ignoresSafeArea())
    .environment(\.colorScheme, .dark) // 🔹 Try toggling to .light
}
