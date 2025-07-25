import SwiftUI

struct LoginView: View {
    @StateObject private var vm = LoginViewModel()
    let onSwitch: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            AnimatedFieldContainer(delay: 0.1) {
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
            }

            AnimatedFieldContainer(delay: 0.2) {
                InputField(placeholder: "Email", text: $vm.email, systemImage: "envelope.fill")
            }

            AnimatedFieldContainer(delay: 0.3) {
                SecureInputField(placeholder: "Password", text: $vm.password, systemImage: "lock.fill")
            }

            if let error = vm.errorMessage {
                AnimatedFieldContainer(delay: 0.35) {
                    Text(error).foregroundColor(.red)
                }
            }

            AnimatedFieldContainer(delay: 0.4) {
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
            }

            AnimatedFieldContainer(delay: 0.5) {
                Button("Don't have an account? Sign up") {
                    withAnimation(.easeInOut) {
                        onSwitch()
                    }
                }
                .padding(.top)
            }
        }
        .padding()
        .navigationTitle("Login")
    }
}

#Preview {
    LoginView(onSwitch: {})
}
