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
                    
                    // Expandable Sections
                    VStack(spacing: 20) {
                        // Investments Section Header
                        SectionHeaderButton(
                            title: "Investments",
                            isExpanded: expandedSections.contains(.investments),
                            onToggle: { toggleSection(.investments) }
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Investments Section
                        if expandedSections.contains(.investments) {
                            AssetCategorySection(
                                category: .investments,
                                assets: viewModel.assets.filter { $0.category == .investments },
                                viewModel: viewModel
                            )
                        }
                        
                        // Loans Section Header
                        SectionHeaderButton(
                            title: "Loans",
                            isExpanded: expandedSections.contains(.loans),
                            onToggle: { toggleSection(.loans) }
                        )
                        .padding(.horizontal)
                        
                        // Loans Section
                        if expandedSections.contains(.loans) {
                            AssetCategorySection(
                                category: .loans,
                                assets: viewModel.assets.filter { $0.category == .loans },
                                viewModel: viewModel
                            )
                        }
                        
                        // Insurance Section Header
                        SectionHeaderButton(
                            title: "Insurance",
                            isExpanded: expandedSections.contains(.insurance),
                            onToggle: { toggleSection(.insurance) }
                        )
                        .padding(.horizontal)
                        
                        // Insurance Section
                        if expandedSections.contains(.insurance) {
                            AssetCategorySection(
                                category: .insurance,
                                assets: viewModel.assets.filter { $0.category == .insurance },
                                viewModel: viewModel
                            )
                        }
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

struct SectionHeaderButton: View {
    let title: String
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                onToggle()
            }
        }) {
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
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
