import SwiftUI

struct SignupView: View {
    @StateObject private var vm = SignupViewModel()
    let onSwitch: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // 🔹 Title
            AnimatedFieldContainer(delay: 0.1) {
                VStack(spacing: 4) {
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextPrimary"))

                    Text("Join us to get started")
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                }
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
            }

            // 🔹 Name
            AnimatedFieldContainer(delay: 0.2) {
                InputField(
                    placeholder: "Name",
                    text: $vm.name,
                    systemImage: "person",
                    characterLimit: 50
                )
            }

            // 🔹 Email
            AnimatedFieldContainer(delay: 0.3) {
                InputField(
                    placeholder: "Email",
                    text: $vm.email,
                    systemImage: "envelope",
                    characterLimit: 100
                )
            }

            // 🔹 Password
            AnimatedFieldContainer(delay: 0.4) {
                SecureInputField(
                    placeholder: "Password",
                    text: $vm.password,
                    systemImage: "lock"
                )
            }

            // 🔹 Confirm Password
            AnimatedFieldContainer(delay: 0.5) {
                SecureInputField(
                    placeholder: "Confirm Password",
                    text: $vm.confirmPassword,
                    systemImage: "lock.rotation"
                )
            }

            // 🔹 Error Message
            if let error = vm.errorMessage {
                AnimatedFieldContainer(delay: 0.55) {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            // 🔹 Signup Button
            AnimatedFieldContainer(delay: 0.6) {
                Button(action: {
                    Task { await vm.signup() }
                }) {
                    if vm.isLoading {
                        ProgressView()
                            .tint(Color("TextPrimary"))
                    } else {
                        Text("Sign Up")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Primary"))
                            .foregroundColor(Color("TextPrimary"))
                            .cornerRadius(12)
                    }
                }
                .disabled(!vm.isFormPartiallyValid || vm.isLoading)
            }

            // 🔹 Switch to Login
            AnimatedFieldContainer(delay: 0.7) {
                Button(action: {
                    withAnimation(.easeInOut) { onSwitch() }
                }) {
                    Text("Already have an account? Log in")
                        .font(.footnote)
                        .foregroundColor(Color("Primary"))
                }
                .padding(.top)
            }
        }
        .padding()
        .background(Color("Background").ignoresSafeArea())
    }
}

#Preview {
    Group {
        SignupView(onSwitch: {})
            .preferredColorScheme(.dark)
    }
}
