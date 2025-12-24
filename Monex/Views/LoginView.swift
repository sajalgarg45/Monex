import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showingSignup = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // App logo and title
                VStack(spacing: 12) {
                    Text("Monex")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Where money feels simple")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
                
                // Login form
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(16)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
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
                
                // Login button
                Button(action: {
                    login()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                    } else {
                        Text("Login")
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
                
                // Sign up option
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showingSignup = true
                    }) {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.top, 5)
                .sheet(isPresented: $showingSignup) {
                    SignupView(viewModel: viewModel)
                }
                
                Spacer()
                
                // App features preview
                VStack(spacing: 12) {
                    Text("Start managing your finances")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 30) {
                        FeatureItem(icon: "chart.pie.fill", title: "Budgeting")
                        FeatureItem(icon: "creditcard.fill", title: "Expenses")
                        FeatureItem(icon: "chart.line.uptrend.xyaxis", title: "Analytics")
                    }
                    .padding(.top, 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .padding()
        }
    }
    
    private func login() {
        // Validation
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
            errorMessage = "Please enter your password"
            return
        }
        
        guard password.count >= 6 else {
            showError = true
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        isLoading = true
        showError = false
        
        // Attempt login
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let success = viewModel.login(email: email, password: password)
            isLoading = false
            
            if !success {
                showError = true
                errorMessage = "Invalid email or password"
            }
        }
    }
}

struct FeatureItem: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.primary)
                .frame(width: 50, height: 50)
                .background(Color.primary.opacity(0.08))
                .clipShape(Circle())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    LoginView(viewModel: BudgetViewModel())
} 