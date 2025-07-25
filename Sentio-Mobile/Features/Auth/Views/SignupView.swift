import SwiftUI

struct SignupView: View {
    @StateObject private var vm = SignupViewModel()
    let onSwitch: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Join us to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.bottom, 10)
            
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

            Button("Already have an account? Log in") {
                onSwitch()
            }
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
    SignupView(onSwitch: {})
}
