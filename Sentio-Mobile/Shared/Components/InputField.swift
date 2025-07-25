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
                    .foregroundColor(.gray)
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .autocapitalization(.none)
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )

            if let limit = characterLimit {
                Text("\(text.count)/\(limit)")
                    .font(.caption2)
                    .foregroundColor(text.count < 2 ? .orange : .gray)
                    .padding(.top, 6)
                    .padding(.trailing, 12)
            }
        }
    }
}

#Preview {
    InputField(
        placeholder: "Enter your profession",
        text: .constant("Developer"),
        systemImage: "briefcase.fill",
        characterLimit: 100
    )
    .padding()
}
