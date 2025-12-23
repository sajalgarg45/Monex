import SwiftUI

struct EditBudgetView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BudgetViewModel
    @Binding var budget: Budget
    
    @State private var name: String
    @State private var amount: String
    @State private var icon: String
    @State private var color: String
    
    private let icons = ["cart.fill", "fork.knife", "house.fill", "creditcard.fill", "airplane", "heart.fill", "book.fill", "dollarsign.circle.fill"]
    private let colors = ["blue", "red", "green", "orange", "purple", "yellow", "pink", "indigo"]
    
    init(viewModel: BudgetViewModel, budget: Binding<Budget>) {
        self.viewModel = viewModel
        self._budget = budget
        
        // Initialize state with current budget values
        self._name = State(initialValue: budget.wrappedValue.name)
        self._amount = State(initialValue: String(format: "%.0f", budget.wrappedValue.amount))
        self._icon = State(initialValue: budget.wrappedValue.icon)
        self._color = State(initialValue: budget.wrappedValue.color)
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !amount.isEmpty && Double(amount) ?? 0 > 0
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Budget Details")) {
                    TextField("Budget Name", text: $name)
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Icon")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
                        ForEach(icons, id: \.self) { iconName in
                            IconButton(
                                iconName: iconName,
                                isSelected: icon == iconName,
                                onTap: { icon = iconName },
                                color: color
                            )
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                Section(header: Text("Color")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
                        ForEach(colors, id: \.self) { colorName in
                            ColorButton(
                                colorName: colorName,
                                isSelected: color == colorName,
                                onTap: { color = colorName }
                            )
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationTitle("Edit Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let amountValue = Double(amount) {
                            var updatedBudget = budget
                            updatedBudget.name = name
                            updatedBudget.amount = amountValue
                            updatedBudget.icon = icon
                            updatedBudget.color = color
                            
                            viewModel.updateBudget(updatedBudget)
                            budget = updatedBudget
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
}

#Preview {
    let viewModel = BudgetViewModel()
    return EditBudgetView(viewModel: viewModel, budget: .constant(Budget.sampleBudgets[0]))
}