import SwiftUI

struct SignupView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemBackground),
                    Color.blue.opacity(0.1),
                    Color(UIColor.systemBackground)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 110, height: 110)
                        
                        Image(systemName: "person.crop.circle.badge.plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [.blue, .blue.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 5)
                    }
                    
                    Text("Create Account")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.primary, .primary.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Start your financial journey")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
                
                // Signup form
                VStack(spacing: 20) {
                    TextField("Full Name", text: $name)
                        .autocapitalization(.words)
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                    
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                }
                .padding(.horizontal)
                
                // Error message
                if showError {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                // Sign up button
                Button(action: {
                    signup()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.blue.gradient)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                    } else {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.blue.gradient)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                }
                .disabled(isLoading)
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Login option
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Login")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 5)
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func signup() {
        // Validation
        guard !name.isEmpty else {
            showError = true
            errorMessage = "Please enter your name"
            return
        }
        
        guard !email.isEmpty else {
            showError = true
            errorMessage = "Please enter your email"
            return
        }
        
        guard email.contains("@") && email.contains(".") else {
            showError = true
            errorMessage = "Please enter a valid email"
            return
        }
        
        guard !password.isEmpty else {
            showError = true
            errorMessage = "Please enter a password"
            return
        }
        
        guard password.count >= 6 else {
            showError = true
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        guard password == confirmPassword else {
            showError = true
            errorMessage = "Passwords do not match"
            return
        }
        
        isLoading = true
        showError = false
        
        // Simulate signup process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            viewModel.signup(name: name, email: email, password: password)
            isLoading = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    SignupView(viewModel: BudgetViewModel())
}
