import SwiftUI

struct SignupView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                Spacer()
                    .frame(height: 50)
                
                // Header
                VStack(spacing: 12) {
                    Text("Create Account")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Start your financial journey")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
                
                // Signup form
                VStack(spacing: 20) {
                    TextField("First Name", text: $firstName)
                        .autocapitalization(.words)
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                    
                    TextField("Last Name", text: $lastName)
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
                            .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                    } else {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                    }
                }
                .background(.ultraThinMaterial)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
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
                            .foregroundColor(.primary)
                    }
                }
                .padding(.top, 5)
                
                Spacer(minLength: 40)
                }
                .padding()
            }
        }
    }
    
    private func signup() {
        // Validation
        guard !firstName.isEmpty else {
            showError = true
            errorMessage = "Please enter your first name"
            return
        }
        
        guard !lastName.isEmpty else {
            showError = true
            errorMessage = "Please enter your last name"
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
            viewModel.signup(firstName: firstName, lastName: lastName, email: email, password: password)
            isLoading = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    SignupView(viewModel: BudgetViewModel())
}
