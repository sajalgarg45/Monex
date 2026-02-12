import SwiftUI

struct InvestmentsView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @State private var showingAddAsset = false
    @State private var expandedSections: Set<Asset.AssetCategory> = [.investments, .liabilities, .insurance]
    
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
                    
                    // Net Worth Card
                    NetWorthCard(viewModel: viewModel)
                        .padding(.horizontal)
                    
                    // Investments Section
                    AssetSection(
                        category: .investments,
                        assets: viewModel.assets.filter { $0.category == .investments },
                        isExpanded: expandedSections.contains(.investments),
                        onToggle: { toggleSection(.investments) },
                        onDelete: { asset in viewModel.deleteAsset(asset) }
                    )
                    
                    // Liabilities Section
                    AssetSection(
                        category: .liabilities,
                        assets: viewModel.assets.filter { $0.category == .liabilities },
                        isExpanded: expandedSections.contains(.liabilities),
                        onToggle: { toggleSection(.liabilities) },
                        onDelete: { asset in viewModel.deleteAsset(asset) }
                    )
                    
                    // Insurance Section
                    AssetSection(
                        category: .insurance,
                        assets: viewModel.assets.filter { $0.category == .insurance },
                        isExpanded: expandedSections.contains(.insurance),
                        onToggle: { toggleSection(.insurance) },
                        onDelete: { asset in viewModel.deleteAsset(asset) }
                    )
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddAsset = true
                    } label: {
                        Image(systemName: "plus")
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
        if expandedSections.contains(category) {
            expandedSections.remove(category)
        } else {
            expandedSections.insert(category)
        }
    }
}

struct NetWorthCard: View {
    @ObservedObject var viewModel: BudgetViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.green)
                        Text("Net Worth")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("₹\(Int(viewModel.netWorth))")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(minWidth: 120, alignment: .leading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Summary Row
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Investments")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("₹\(Int(viewModel.totalInvestments))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Liabilities")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("₹\(Int(viewModel.totalLiabilities))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.red)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Insurance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("₹\(Int(viewModel.totalInsurance))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 2)
    }
}

struct AssetSection: View {
    let category: Asset.AssetCategory
    let assets: [Asset]
    let isExpanded: Bool
    let onToggle: () -> Void
    let onDelete: (Asset) -> Void
    
    var totalAmount: Double {
        assets.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            Button(action: onToggle) {
                HStack {
                    Image(systemName: category.icon)
                        .font(.system(size: 18))
                        .foregroundColor(categoryColor)
                    
                    Text(category.rawValue)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("₹\(Int(totalAmount))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
            
            // Asset Items
            if isExpanded {
                if assets.isEmpty {
                    HStack {
                        Spacer()
                        Text("No \(category.rawValue.lowercased()) added yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 12)
                        Spacer()
                    }
                    .padding(.horizontal)
                } else {
                    ForEach(assets) { asset in
                        AssetRow(asset: asset, onDelete: { onDelete(asset) })
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private var categoryColor: Color {
        switch category {
        case .investments:
            return .green
        case .liabilities:
            return .red
        case .insurance:
            return .blue
        }
    }
}

struct AssetRow: View {
    let asset: Asset
    let onDelete: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(assetColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: asset.type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(assetColor)
            }
            
            // Asset Info
            VStack(alignment: .leading, spacing: 6) {
                Text(asset.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(asset.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text("₹\(Int(asset.amount))")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .frame(minWidth: 80, alignment: .trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.tertiarySystemGroupedBackground))
        )
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var assetColor: Color {
        switch asset.type.color {
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "purple": return .purple
        case "orange": return .orange
        case "red": return .red
        case "cyan": return .cyan
        default: return .gray
        }
    }
}

#Preview {
    let viewModel = BudgetViewModel()
    return InvestmentsView(viewModel: viewModel)
}
