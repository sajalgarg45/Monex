import SwiftUI

struct EditExpenseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BudgetViewModel
    @Binding var budget: Budget
    
    let expense: Expense
    
    @State private var title: String
    @State private var amount: String
    @State private var date: Date
    @State private var note: String
    
    init(viewModel: BudgetViewModel, budget: Binding<Budget>, expense: Expense) {
        self.viewModel = viewModel
        self._budget = budget
        self.expense = expense
        
        // Initialize state with current expense values
        self._title = State(initialValue: expense.title)
        self._amount = State(initialValue: String(format: "%.0f", expense.amount))
        self._date = State(initialValue: expense.date)
        self._note = State(initialValue: expense.note)
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && !amount.isEmpty && Double(amount) ?? 0 > 0
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Title", text: $title)
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section(header: Text("Note (Optional)")) {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Expense")
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
                            if let index = budget.expenses.firstIndex(where: { $0.id == expense.id }) {
                                // Create updated expense
                                var updatedExpense = expense
                                updatedExpense.title = title
                                updatedExpense.amount = amountValue
                                updatedExpense.date = date
                                updatedExpense.note = note
                                
                                // Update expense in budget
                                budget.expenses[index] = updatedExpense
                                
                                // Update budget in viewModel
                                viewModel.updateBudget(budget)
                                
                                presentationMode.wrappedValue.dismiss()
                            }
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
    var budget = Budget.sampleBudgets[0]
    budget.expenses = Expense.sampleExpenses
    return EditExpenseView(viewModel: viewModel, budget: .constant(budget), expense: budget.expenses[0])
} 