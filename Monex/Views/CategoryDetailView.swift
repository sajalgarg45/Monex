import SwiftUI

struct CategoryDetailView: View {
    let category: Asset.AssetCategory
    @ObservedObject var viewModel: BudgetViewModel
    @State private var showingAddAsset = false
    
    private var categoryIcon: String {
        switch category {
        case .investments:
            return "arrow.up.right.circle.fill"
        case .loans:
            return "arrow.down.circle.fill"
        case .insurance:
            return "shield.fill"
        }
    }
    
    private var categoryColor: Color {
        switch category {
        case .investments:
            return .green
        case .loans:
            return .red
        case .insurance:
            return .blue
        }
    }
    
    private var categoryAssets: [Asset] {
        viewModel.assets.filter { $0.category == category }
    }
    
    private var totalAmount: Double {
        switch category {
        case .investments:
            return viewModel.totalInvestments
        case .loans:
            return viewModel.totalLiabilities
        case .insurance:
            return viewModel.totalInsurance
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Summary Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(categoryColor.opacity(0.2))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: categoryIcon)
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(categoryColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total \(category.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("₹\(totalAmount, specifier: "%.0f")")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                        
                        Spacer()
                    }
                    
                    if !categoryAssets.isEmpty {
                        Divider()
                        
                        HStack {
                            Text("\(categoryAssets.count) items")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Assets List
                if categoryAssets.isEmpty {
                    emptyState
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your \(category.rawValue)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        ForEach(categoryAssets) { asset in
                            if category == .loans {
                                NavigationLink(destination: LoanDetailView(asset: asset, viewModel: viewModel)) {
                                    AssetCard(asset: asset, viewModel: viewModel)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            } else {
                                AssetCard(asset: asset, viewModel: viewModel)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(category.rawValue)
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
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(UIColor.tertiarySystemGroupedBackground))
                    .frame(width: 120, height: 120)
                
                Image(systemName: categoryIcon)
                    .font(.system(size: 50))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text("No \(category.rawValue) Yet")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Add your first \(category.rawValue.lowercased()) to start tracking")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button {
                showingAddAsset = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add \(category.rawValue)")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(categoryColor)
                .cornerRadius(12)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

#Preview {
    let viewModel = BudgetViewModel()
    return NavigationView {
        CategoryDetailView(category: .investments, viewModel: viewModel)
    }
}
