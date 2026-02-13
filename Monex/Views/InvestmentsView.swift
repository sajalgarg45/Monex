import SwiftUI

struct InvestmentsView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @State private var showingAddAsset = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your Assets")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Track Where Your Wealth\nLives")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Summary Cards Grid (2x2) - Same style as Dashboard
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            AssetSummaryCard(title: "Net Worth", value: viewModel.netWorth, iconName: "chart.bar.fill", color: .green)
                            AssetSummaryCard(title: "Investments", value: viewModel.totalInvestments, iconName: "arrow.up.right.circle.fill", color: .green)
                        }
                        
                        HStack(spacing: 16) {
                            AssetSummaryCard(title: "Loans", value: viewModel.totalLiabilities, iconName: "arrow.down.circle.fill", color: .red)
                            AssetSummaryCard(title: "Insurance", value: viewModel.totalInsurance, iconName: "shield.fill", color: .blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Select Category Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Category")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        VStack(spacing: 16) {
                            NavigationLink(destination: CategoryDetailView(category: .investments, viewModel: viewModel)) {
                                CategoryNavigationCard(
                                    title: "Investments",
                                    subtitle: "Mutual Funds, Stocks, Gold, FD",
                                    icon: "arrow.up.right.circle.fill",
                                    color: .green
                                )
                            }
                            
                            NavigationLink(destination: CategoryDetailView(category: .loans, viewModel: viewModel)) {
                                CategoryNavigationCard(
                                    title: "Loans",
                                    subtitle: "Home, Car, Education Loans",
                                    icon: "arrow.down.circle.fill",
                                    color: .red
                                )
                            }
                            
                            NavigationLink(destination: CategoryDetailView(category: .insurance, viewModel: viewModel)) {
                                CategoryNavigationCard(
                                    title: "Insurance",
                                    subtitle: "Health, Life, LIC Policies",
                                    icon: "shield.fill",
                                    color: .blue
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddAsset = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                    }
                }
            }
            .sheet(isPresented: $showingAddAsset) {
                AddAssetView(viewModel: viewModel)
            }
        }
        .navigationViewStyle(.stack)
    }
}

// Reusing the exact same card design from Dashboard
struct AssetSummaryCard: View {
    let title: String
    let value: Double
    let iconName: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Text("₹\(value, specifier: "%.0f")")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .frame(minWidth: 80, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 2)
    }
}

struct CategoryNavigationCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 70, height: 70)
                
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.06), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    let viewModel = BudgetViewModel()
    return InvestmentsView(viewModel: viewModel)
}
