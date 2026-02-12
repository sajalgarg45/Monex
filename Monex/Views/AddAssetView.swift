import SwiftUI

struct AddAssetView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedCategory: Asset.AssetCategory?
    @State private var selectedType: Asset.AssetType?
    
    var body: some View {
        NavigationView {
            if selectedCategory == nil {
                CategorySelectionView(selectedCategory: $selectedCategory)
            } else if selectedType == nil {
                TypeSelectionView(
                    category: selectedCategory!,
                    selectedType: $selectedType,
                    onBack: { selectedCategory = nil }
                )
            } else {
                AssetFormView(
                    category: selectedCategory!,
                    type: selectedType!,
                    viewModel: viewModel,
                    onBack: { selectedType = nil },
                    onSave: {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
}

struct CategorySelectionView: View {
    @Binding var selectedCategory: Asset.AssetCategory?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Add Asset")
                    .font(.headline)
                
                Spacer()
                
                // Invisible button for balance
                Button("Cancel") {
                }
                .opacity(0)
                .disabled(true)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            Divider()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("Select Category")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        CategoryCard(
                            title: "Investments",
                            subtitle: "Mutual Funds, Stocks, Gold, FD",
                            icon: "arrow.up.right.circle.fill",
                            color: .green
                        ) {
                            selectedCategory = .investments
                        }
                        
                        CategoryCard(
                            title: "Loans",
                            subtitle: "Home, Car, Education Loans",
                            icon: "arrow.down.right.circle.fill",
                            color: .red
                        ) {
                            selectedCategory = .loans
                        }
                        
                        CategoryCard(
                            title: "Insurance",
                            subtitle: "Health, Life, LIC Policies",
                            icon: "shield.checkered",
                            color: .blue
                        ) {
                            selectedCategory = .insurance
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
}

struct CategoryCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TypeSelectionView: View {
    let category: Asset.AssetCategory
    @Binding var selectedType: Asset.AssetType?
    let onBack: () -> Void
    
    var availableTypes: [Asset.AssetType] {
        switch category {
        case .investments:
            return [.mutualFunds, .stocks, .gold, .fixedDeposit]
        case .loans:
            return [.homeLoan, .carLoan, .educationLoan, .otherLoan]
        case .insurance:
            return [.healthInsurance, .lifeInsurance, .lic]
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text(category.rawValue)
                    .font(.headline)
                
                Spacer()
                
                // Invisible button for balance
                Button("Back") {}
                    .opacity(0)
                    .disabled(true)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            Divider()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("Select Type")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        ForEach(availableTypes, id: \.self) { type in
                            TypeCard(type: type) {
                                selectedType = type
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
}

struct TypeCard: View {
    let type: Asset.AssetType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(typeColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(typeColor)
                }
                
                Text(type.rawValue)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var typeColor: Color {
        switch type.color {
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "purple": return .purple
        case "orange": return .orange
        case "red": return .red
        case "cyan": return .cyan
        case "indigo": return .indigo
        case "pink": return .pink
        case "teal": return .teal
        default: return .gray
        }
    }
}

#Preview {
    let viewModel = BudgetViewModel()
    return AddAssetView(viewModel: viewModel)
}
