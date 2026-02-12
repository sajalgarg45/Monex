import SwiftUI

struct InvestmentsView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @State private var showingAddAsset = false
    @State private var expandedSections: Set<Asset.AssetCategory> = [.investments, .loans, .insurance]
    
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
                    
                    // Net Worth Card - Separated
                    NetWorthCard(viewModel: viewModel)
                        .padding(.horizontal)
                    
                    // Category Summary Cards
                    VStack(spacing: 12) {
                        CategorySummaryCard(
                            title: "Investments",
                            amount: viewModel.totalInvestments,
                            icon: "arrow.up.right.circle.fill",
                            color: .green,
                            isExpanded: expandedSections.contains(.investments),
                            onToggle: { toggleSection(.investments) }
                        )
                        
                        CategorySummaryCard(
                            title: "Loans",
                            amount: viewModel.totalLiabilities,
                            icon: "arrow.down.right.circle.fill",
                            color: .red,
                            isExpanded: expandedSections.contains(.loans),
                            onToggle: { toggleSection(.loans) }
                        )
                        
                        CategorySummaryCard(
                            title: "Insurance",
                            amount: viewModel.totalInsurance,
                            icon: "shield.checkered",
                            color: .blue,
                            isExpanded: expandedSections.contains(.insurance),
                            onToggle: { toggleSection(.insurance) }
                        )
                    }
                    .padding(.horizontal)
                    
                    // Investments Section
                    if expandedSections.contains(.investments) {
                        AssetCategorySection(
                            category: .investments,
                            assets: viewModel.assets.filter { $0.category == .investments },
                            viewModel: viewModel
                        )
                    }
                    
                    // Loans Section
                    if expandedSections.contains(.loans) {
                        AssetCategorySection(
                            category: .loans,
                            assets: viewModel.assets.filter { $0.category == .loans },
                            viewModel: viewModel
                        )
                    }
                    
                    // Insurance Section
                    if expandedSections.contains(.insurance) {
                        AssetCategorySection(
                            category: .insurance,
                            assets: viewModel.assets.filter { $0.category == .insurance },
                            viewModel: viewModel
                        )
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
    
    private func toggleSection(_ category: Asset.AssetCategory) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if expandedSections.contains(category) {
                expandedSections.remove(category)
            } else {
                expandedSections.insert(category)
            }
        }
    }
}

struct NetWorthCard: View {
    @ObservedObject var viewModel: BudgetViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Net Worth")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text("₹\(formatAmount(viewModel.netWorth))")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.08), radius: 10, x: 0, y: 4)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        if amount < 0 {
            return "-\(Int(abs(amount)).formatted())"
        }
        return Int(amount).formatted()
    }
}

struct CategorySummaryCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    let isExpanded: Bool
    let onToggle: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("₹\(formatAmount(amount))")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.06), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatAmount(_ amount: Double) -> String {
        Int(amount).formatted()
    }
}

struct AssetCategorySection: View {
    let category: Asset.AssetCategory
    let assets: [Asset]
    @ObservedObject var viewModel: BudgetViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            if assets.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: category.icon)
                            .font(.system(size: 40))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("No \(category.rawValue.lowercased()) added yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 30)
                    Spacer()
                }
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding(.horizontal)
            } else {
                ForEach(assets) { asset in
                    AssetCard(asset: asset, viewModel: viewModel)
                        .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    let viewModel = BudgetViewModel()
    return InvestmentsView(viewModel: viewModel)
}
