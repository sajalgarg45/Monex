import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    
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
                // App logo and title
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 110, height: 110)
                        
                        Image(systemName: "dollarsign.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [.blue, .blue.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 5)
                    }
                    
                    Text("Finance Assistant")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.primary, .primary.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
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
                
                // Login button
                Button(action: {
                    isLoading = true
                    // Simulate login process
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        viewModel.login()
                        isLoading = false
                    }
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
                        Text("Login")
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
                
                // Sign up option
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        // Show registration view (not implemented for this demo)
                    }) {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 5)
                
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
}

struct FeatureItem: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.blue)
                .frame(width: 50, height: 50)
                .background(Color.blue.opacity(0.1))
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