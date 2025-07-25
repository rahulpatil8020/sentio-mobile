import SwiftUI

struct SignupView: View {
    @StateObject private var vm = SignupViewModel()
    let onSwitch: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            AnimatedFieldContainer(delay: 0.1) {
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
            }

            AnimatedFieldContainer(delay: 0.2) {
                InputField(placeholder: "Name", text: $vm.name, systemImage: "person", characterLimit: 50)
            }

            AnimatedFieldContainer(delay: 0.3) {
                InputField(placeholder: "Email", text: $vm.email, systemImage: "envelope", characterLimit: 100)
            }

            AnimatedFieldContainer(delay: 0.4) {
                SecureInputField(placeholder: "Password", text: $vm.password, systemImage: "lock")
            }

            AnimatedFieldContainer(delay: 0.5) {
                SecureInputField(placeholder: "Confirm Password", text: $vm.confirmPassword, systemImage: "lock.rotation")
            }

            if let error = vm.errorMessage {
                AnimatedFieldContainer(delay: 0.55) {
                    Text(error).foregroundColor(.red)
                }
            }

            AnimatedFieldContainer(delay: 0.6) {
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
            }

            AnimatedFieldContainer(delay: 0.7) {
                Button("Already have an account? Log in") {
                    withAnimation(.easeInOut) {
                        onSwitch()
                    }
                }
                .padding(.top)
            }
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
