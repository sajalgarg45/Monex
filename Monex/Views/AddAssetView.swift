import SwiftUI

struct AddAssetView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var assetName = ""
    @State private var assetAmount = ""
    @State private var selectedCategory: Asset.AssetCategory = .investments
    @State private var selectedType: Asset.AssetType = .mutualFunds
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Asset Details")) {
                    TextField("Asset Name", text: $assetName)
                    
                    TextField("Amount", text: $assetAmount)
                        .keyboardType(.numberPad)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(Asset.AssetCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .onChange(of: selectedCategory) { newCategory in
                        // Update selected type based on category
                        selectedType = availableTypes(for: newCategory).first ?? .mutualFunds
                    }
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(availableTypes(for: selectedCategory), id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                }
                
                Section(header: Text("Notes (Optional)")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Asset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAsset()
                    }
                    .fontWeight(.semibold)
                    .disabled(assetName.isEmpty || assetAmount.isEmpty)
                }
            }
        }
    }
    
    private func availableTypes(for category: Asset.AssetCategory) -> [Asset.AssetType] {
        switch category {
        case .investments:
            return [.mutualFunds, .stocks, .gold, .fixedDeposit]
        case .liabilities:
            return [.homeLoan, .carLoan]
        case .insurance:
            return [.lic]
        }
    }
    
    private func saveAsset() {
        guard let amount = Double(assetAmount) else { return }
        
        let newAsset = Asset(
            name: assetName,
            amount: amount,
            type: selectedType,
            category: selectedCategory,
            notes: notes,
            dateAdded: Date()
        )
        
        viewModel.addAsset(newAsset)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    let viewModel = BudgetViewModel()
    return AddAssetView(viewModel: viewModel)
}
