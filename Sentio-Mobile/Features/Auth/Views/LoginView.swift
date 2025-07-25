import SwiftUI

struct LoginView: View {
    @StateObject private var vm = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // 📧 Email Field
            InputField(
                placeholder: "Email",
                text: $vm.email,
                systemImage: "envelope.fill"
            )
            
            // 🔒 Password Field with visibility toggle
            SecureInputField(
                placeholder: "Password",
                text: $vm.password,
                systemImage: "lock.fill"
            )
            
            // ❌ Error message
            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            // 🔓 Login Button
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
            
            // 🔁 Navigation to Signup
            NavigationLink("Don't have an account? Sign up", destination: SignupView())
                .padding(.top)
        }
        .padding()
        .navigationTitle("Login")
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
