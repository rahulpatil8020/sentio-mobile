import SwiftUI

struct LoginView: View {
    @StateObject private var vm = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $vm.email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
            
            SecureField("Password", text: $vm.password)
                .textFieldStyle(.roundedBorder)
            
            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
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
            
            NavigationLink("Don't have an account? Sign up", destination: SignupView())
                .padding(.top)
        }
        .padding()
        .navigationTitle("Login")
    }
}

#Preview {
    LoginView()
}
