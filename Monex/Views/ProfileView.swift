import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BudgetViewModel
    @State private var showingEditProfile = false
    @State private var alertsEnabled = true
    @State private var privacySecurityEnabled = true
    @State private var showingHelpAlert = false
    @State private var showingAboutAlert = false
    
    var userInitials: String {
        guard let user = viewModel.currentUser else { return "NA" }
        let first = String(user.firstName.prefix(1))
        let last = String(user.lastName.prefix(1))
        return (first + last).uppercased()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Profile Header Card - Horizontal Layout
                    HStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 80, height: 80)
                            
                            Text(userInitials)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text(viewModel.currentUser?.name ?? "User")
                            .font(.system(size: 28, weight: .bold))
                        
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.bottom, 10)
                    
                    // Profile Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Profile")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                        
                        VStack(spacing: 0) {
                            Button(action: {
                                showingEditProfile = true
                            }) {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                    
                                    Text("Edit Profile")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "pencil")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal)
                            }
                        }
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Alerts & Privacy Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Preferences")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.orange)
                                    .frame(width: 30)
                                
                                Text("Alerts")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Toggle("", isOn: $alertsEnabled)
                                    .labelsHidden()
                            }
                            .padding(.vertical, 15)
                            .padding(.horizontal)
                            
                            Divider()
                                .padding(.leading, 50)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.purple)
                                    .frame(width: 30)
                                
                                Text("Privacy & Security")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Toggle("", isOn: $privacySecurityEnabled)
                                    .labelsHidden()
                            }
                            .padding(.vertical, 15)
                            .padding(.horizontal)
                        }
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Help & About Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Support")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                        
                        VStack(spacing: 0) {
                            Button(action: {
                                showingHelpAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "questionmark.circle.fill")
                                        .foregroundColor(.cyan)
                                        .frame(width: 30)
                                    
                                    Text("Help & Support")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal)
                            }
                            
                            Divider()
                                .padding(.leading, 50)
                            
                            Button(action: {
                                showingAboutAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                    
                                    Text("About")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal)
                            }
                            
                            Divider()
                                .padding(.leading, 50)
                            
                            Button {
                                viewModel.logout()
                            } label: {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundColor(.red)
                                        .frame(width: 30)
                                    
                                    Text("Log Out")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal)
                            }
                        }
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                .padding()
                .padding(.bottom, 80)
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(viewModel: viewModel)
            }
            .alert("Help & Support", isPresented: $showingHelpAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("For assistance, please contact us at support@monex.com or visit our website.")
            }
            .alert("About Monex", isPresented: $showingAboutAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Monex v1.0\\nA simple and elegant way to manage your finances.\\n\\n© 2025 Monex. All rights reserved.")
            }
        }
    }
}

// Edit Profile View
struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BudgetViewModel
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    HStack {
                        Text("First Name")
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("First Name", text: $firstName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Last Name")
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("Last Name", text: $lastName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Email")
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("Email", text: $email)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    HStack {
                        Text("Password")
                            .foregroundColor(.secondary)
                        Spacer()
                        Group {
                            if showPassword {
                                TextField("Password", text: $password)
                                    .multilineTextAlignment(.trailing)
                            } else {
                                SecureField("Password", text: $password)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Update user data
                        if var user = viewModel.currentUser {
                            user.firstName = firstName
                            user.lastName = lastName
                            user.email = email
                            viewModel.currentUser = user
                            viewModel.saveUserData(user)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                firstName = viewModel.currentUser?.firstName ?? ""
                lastName = viewModel.currentUser?.lastName ?? ""
                email = viewModel.currentUser?.email ?? ""
                password = "" // Leave empty for security, user can set new password
            }
        }
    }
}

struct ProfileStatCard: View {
    let title: String
    let value: String
    let iconName: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ProfileMenuRow: View {
    let title: String
    let iconName: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 15)
            .padding(.horizontal)
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        Divider()
            .padding(.leading, 56)
    }
}

#Preview {
    let viewModel = BudgetViewModel()
    viewModel.login() // Login to show mock user data
    return ProfileView(viewModel: viewModel)
} 
