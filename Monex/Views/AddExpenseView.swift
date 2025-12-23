import SwiftUI

struct AddExpenseView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BudgetViewModel
    @Binding var budget: Budget
    
    @State private var title = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var note = ""
    
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
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if let amountValue = Double(amount) {
                            let newExpense = Expense(
                                title: title,
                                amount: amountValue,
                                date: date,
                                note: note
                            )
                            
                            // Add expense to the budget
                            budget.expenses.append(newExpense)
                            
                            // Update the budget in the view model
                            viewModel.updateBudget(budget)
                            
                            presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        Text("Save")
                            .fontWeight(.semibold)
                            .primaryButton(color: .green)
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
    return AddExpenseView(viewModel: viewModel, budget: .constant(budget))
} 