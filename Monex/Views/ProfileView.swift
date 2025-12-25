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
        let name = viewModel.currentUser?.name ?? "User"
        let components = name.split(separator: " ")
        if components.count >= 2 {
            let first = String(components[0].prefix(1))
            let last = String(components[1].prefix(1))
            return (first + last).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Profile Header with Initials Circle
                    VStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 100, height: 100)
                            
                            Text(userInitials)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text(viewModel.currentUser?.name ?? "User")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
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
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = "••••••••"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    HStack {
                        Text("Name")
                            .foregroundColor(.secondary)
                        Spacer()
                        TextField("Name", text: $name)
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
                        Text(password)
                            .foregroundColor(.primary)
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
                            user.name = name
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
                name = viewModel.currentUser?.name ?? ""
                email = viewModel.currentUser?.email ?? ""
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
