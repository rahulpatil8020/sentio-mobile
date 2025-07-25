import SwiftUI

struct SignupView: View {
    @StateObject private var vm = SignupViewModel()

    var body: some View {
        VStack(spacing: 20) {
            InputField(placeholder: "Name", text: $vm.name, systemImage: "person", characterLimit: 50)

            InputField(placeholder: "Email", text: $vm.email, systemImage: "envelope", characterLimit: 100)

            SecureInputField(placeholder: "Password", text: $vm.password, systemImage: "lock")

            SecureInputField(placeholder: "Confirm Password", text: $vm.confirmPassword, systemImage: "lock.rotation")

            if let error = vm.errorMessage {
                Text(error).foregroundColor(.red)
            }

            Button(action: {
                Task { await vm.signup() }
            }) {
                if vm.isLoading {
                    ProgressView()
                } else {
                    Text("Sign Up")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!vm.isFormPartiallyValid || vm.isLoading)

            NavigationLink("Already have an account? Log in", destination: LoginView())
                .padding(.top)
        }
        .padding()
        .navigationTitle("Sign Up")
        .navigationDestination(isPresented: $vm.showOnboarding) {
            OnboardingView()
        }
    }
}
#Preview {
    NavigationStack {
        SignupView()
    }
}
