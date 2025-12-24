import SwiftUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BudgetViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Profile Header
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                        
                        Text(viewModel.currentUser?.name ?? "User")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(viewModel.currentUser?.email ?? "user@example.com")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 10)
                    
                    // Settings Section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Settings")
                            .font(.headline)
                            .padding(.leading)
                        
                        VStack(spacing: 0) {
                            ProfileMenuRow(title: "Edit Profile", iconName: "person.fill", iconColor: .blue) {
                                // Navigate to edit profile (not implemented in this example)
                            }
                            
                            ProfileMenuRow(title: "Notifications", iconName: "bell.fill", iconColor: .orange) {
                                // Navigate to notifications settings
                            }
                            
                            ProfileMenuRow(title: "Payment Methods", iconName: "creditcard.fill", iconColor: .green) {
                                // Navigate to payment methods
                            }
                            
                            ProfileMenuRow(title: "Privacy & Security", iconName: "lock.fill", iconColor: .purple) {
                                // Navigate to privacy settings
                            }
                            
                            ProfileMenuRow(title: "Help & Support", iconName: "questionmark.circle.fill", iconColor: .cyan) {
                                // Navigate to help
                            }
                            
                            ProfileMenuRow(title: "About", iconName: "info.circle.fill", iconColor: .blue) {
                                // Navigate to about
                            }
                            
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
                            .background(Color(UIColor.secondarySystemGroupedBackground))
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
