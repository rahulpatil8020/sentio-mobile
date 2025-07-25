import SwiftUI

struct SignupView: View {
    @StateObject private var vm = SignupViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $vm.email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)

            SecureField("Password", text: $vm.password)
                .textFieldStyle(.roundedBorder)

            SecureField("Confirm Password", text: $vm.confirmPassword)
                .textFieldStyle(.roundedBorder)
            
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
            
            NavigationLink("Already have an account? Log in", destination: LoginView())
                .padding(.top)
        }
        .padding()
        .navigationTitle("Sign Up")
        .navigationDestination(isPresented: $vm.showOnboarding) {
            OnboardingView()  // ✅ Navigate here after signup
        }
    }
}

#Preview {
    SignupView()
}
