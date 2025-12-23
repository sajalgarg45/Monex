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
                    
                    // Stats Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Account Summary")
                            .font(.headline)
                            .padding(.leading)
                        
                        HStack(spacing: 16) {
                            ProfileStatCard(
                                title: "Budgets",
                                value: "\(viewModel.budgets.count)",
                                iconName: "folder.fill",
                                color: .blue
                            )
                            
                            ProfileStatCard(
                                title: "Total Tracking",
                                value: "₹\(viewModel.totalBudget)",
                                iconName: "banknote.fill",
                                color: .green
                            )
                        }
                        
                        HStack(spacing: 16) {
                            ProfileStatCard(
                                title: "Total Spent",
                                value: "₹\(viewModel.totalSpent)",
                                iconName: "arrow.down.circle.fill",
                                color: .red
                            )
                            
                            ProfileStatCard(
                                title: "Total Saved",
                                value: "₹\(viewModel.totalRemaining)",
                                iconName: "arrow.up.circle.fill",
                                color: .purple
                            )
                        }
                    }
                    
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
                                presentationMode.wrappedValue.dismiss()
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
                            .background(Color.white)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                .padding()
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
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
        .background(Color.white)
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
        .background(Color.white)
        Divider()
            .padding(.leading, 56)
    }
}

#Preview {
    let viewModel = BudgetViewModel()
    viewModel.login() // Login to show mock user data
    return ProfileView(viewModel: viewModel)
} 
