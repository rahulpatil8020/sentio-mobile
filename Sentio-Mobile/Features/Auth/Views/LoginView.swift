import SwiftUI

struct LoginView: View {
    @StateObject private var vm = LoginViewModel()
    let onSwitch: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // 🔑 App Title
            VStack(spacing: 4) {
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Log in to continue")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.bottom, 10)

            // 📧 Email Field
            InputField(
                placeholder: "Email",
                text: $vm.email,
                systemImage: "envelope.fill"
            )

            // 🔒 Password Field
            SecureInputField(
                placeholder: "Password",
                text: $vm.password,
                systemImage: "lock.fill"
            )

            // ⚠️ Error Message
            if let error = vm.errorMessage {
                Text(error).foregroundColor(.red)
            }

            // ✅ Login Button
            Button(action: {
                Task { await vm.login() }
            }) {
                if vm.isLoading {
                    ProgressView()
                } else {
                    Text("Login")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(vm.email.trimmingCharacters(in: .whitespaces).isEmpty ||
                      vm.password.trimmingCharacters(in: .whitespaces).isEmpty)
            .buttonStyle(.borderedProminent)

            // 🔁 Switch to Signup
            Button("Don't have an account? Sign up") {
                onSwitch()
            }
            .padding(.top)
        }
        .padding()
        .navigationTitle("Login")
    }
}

#Preview {
    LoginView(onSwitch: {})
}
