import SwiftUI

struct LoginView: View {
    @StateObject private var vm = LoginViewModel()
    let onSwitch: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // 🔹 Title
            AnimatedFieldContainer(delay: 0.1) {
                VStack(spacing: 4) {
                    Text("Welcome Back")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextPrimary"))

                    Text("Log in to continue")
                        .font(.subheadline)
                        .foregroundColor(Color("TextSecondary"))
                }
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
            }

            // 🔹 Email
            AnimatedFieldContainer(delay: 0.2) {
                InputField(
                    placeholder: "Email",
                    text: $vm.email,
                    systemImage: "envelope.fill"
                )
            }

            // 🔹 Password
            AnimatedFieldContainer(delay: 0.3) {
                SecureInputField(
                    placeholder: "Password",
                    text: $vm.password,
                    systemImage: "lock.fill"
                )
            }

            // 🔹 Error Message
            if let error = vm.errorMessage {
                AnimatedFieldContainer(delay: 0.35) {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            // 🔹 Login Button
            AnimatedFieldContainer(delay: 0.4) {
                Button(action: {
                    Task { await vm.login() }
                }) {
                    if vm.isLoading {
                        ProgressView()
                            .tint(Color("TextPrimary"))
                    } else {
                        Text("Login")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Primary"))
                            .foregroundColor(Color("TextPrimary"))
                            .cornerRadius(12)
                    }
                }
                .disabled(vm.email.trimmingCharacters(in: .whitespaces).isEmpty ||
                          vm.password.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // 🔹 Switch to Signup
            AnimatedFieldContainer(delay: 0.5) {
                Button(action: {
                    withAnimation(.easeInOut) { onSwitch() }
                }) {
                    Text("Don't have an account? Sign up")
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
        LoginView(onSwitch: {})
            .preferredColorScheme(.dark)

    }
}
