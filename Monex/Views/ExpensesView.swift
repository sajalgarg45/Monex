import SwiftUI

struct ExpensesView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @State private var showingBudgetSelection = false
    @State private var showingAddExpense = false
    @State private var selectedBudget: Budget?
    @State private var showingEditExpense = false
    @State private var selectedExpense: (Budget, Expense)?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Your Expenses")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("See where your money\ngoes")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Recent expenses section
                        VStack(alignment: .leading, spacing: 12) {
                        if getAllExpenses().isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "dollarsign.square.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.secondary.opacity(0.5))
                                
                                Text("No Expenses Yet")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Add an expense to a budget to start tracking your spending")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                            .padding(.top)
                        } else {
                            let groupedExpenses = groupExpensesByDate()
                            
                            ForEach(groupedExpenses.keys.sorted(by: >), id: \.self) { date in
                                if let expenses = groupedExpenses[date], !expenses.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(formatDate(date))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal)
                                            .padding(.top, 8)
                                        
                                        ForEach(expenses) { expenseData in
                                            ExpenseListItem(
                                                budgetName: expenseData.budgetName,
                                                budgetColor: expenseData.budgetColor,
                                                expense: expenseData.expense,
                                                onEdit: {
                                                    selectedExpense = (expenseData.budget, expenseData.expense)
                                                    showingEditExpense = true
                                                },
                                                onDelete: {
                                                    deleteExpense(expenseData)
                                                }
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingBudgetSelection = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingBudgetSelection) {
                BudgetSelectionView(viewModel: viewModel) { budget in
                    selectedBudget = budget
                    showingBudgetSelection = false
                    // Delay slightly to allow first sheet to dismiss before showing next
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showingAddExpense = true
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                if let budget = selectedBudget,
                   let index = viewModel.budgets.firstIndex(where: { $0.id == budget.id }) {
                    let bindingBudget = Binding(
                        get: { viewModel.budgets[index] },
                        set: { viewModel.budgets[index] = $0 }
                    )
                    AddExpenseView(viewModel: viewModel, budget: bindingBudget)
                }
            }
            .sheet(isPresented: $showingEditExpense) {
                if let (budget, expense) = selectedExpense,
                   let index = viewModel.budgets.firstIndex(where: { $0.id == budget.id }) {
                    let bindingBudget = Binding(
                        get: { viewModel.budgets[index] },
                        set: { viewModel.budgets[index] = $0 }
                    )
                    
                    EditExpenseView(viewModel: viewModel, budget: bindingBudget, expense: expense)
                }
            }
        }
    }
    
    // Helper to get total expense count
    private func getTotalExpenseCount() -> Int {
        var count = 0
        for budget in viewModel.budgets {
            count += budget.expenses.count
        }
        return count
    }
    
    // Helper to get all expenses across budgets
    private func getAllExpenses() -> [ExpenseData] {
        var allExpenses: [ExpenseData] = []
        
        for budget in viewModel.budgets {
            for expense in budget.expenses {
                allExpenses.append(
                    ExpenseData(
                        budget: budget,
                        budgetName: budget.name,
                        budgetColor: budget.getColor(),
                        expense: expense
                    )
                )
            }
        }
        
        return allExpenses.sorted(by: { $0.expense.date > $1.expense.date })
    }
    
    // Group expenses by date for section headers
    private func groupExpensesByDate() -> [Date: [ExpenseData]] {
        let calendar = Calendar.current
        var result = [Date: [ExpenseData]]()
        
        for expenseData in getAllExpenses() {
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: expenseData.expense.date)
            if let date = calendar.date(from: dateComponents) {
                if result[date] == nil {
                    result[date] = []
                }
                result[date]?.append(expenseData)
            }
        }
        
        return result
    }
    
    // Format date for section headers
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
    
    // Delete an expense
    private func deleteExpense(_ expenseData: ExpenseData) {
        if let index = viewModel.budgets.firstIndex(where: { $0.id == expenseData.budget.id }) {
            if let expenseIndex = viewModel.budgets[index].expenses.firstIndex(where: { $0.id == expenseData.expense.id }) {
                viewModel.budgets[index].expenses.remove(at: expenseIndex)
                viewModel.updateBudget(viewModel.budgets[index])
            }
        }
    }
}

// Data structure to hold expense with budget info
struct ExpenseData: Identifiable {
    let id = UUID()
    let budget: Budget
    let budgetName: String
    let budgetColor: Color
    let expense: Expense
}

struct ExpenseListItem: View {
    let budgetName: String
    let budgetColor: Color
    let expense: Expense
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(expense.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("• \(budgetName)")
                        .font(.caption)
                        .foregroundColor(budgetColor)
                }
                
                if !expense.note.isEmpty {
                    Text(expense.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("₹\(expense.amount, specifier: "%.0f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(expense.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Menu {
                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .padding(8)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct BudgetSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BudgetViewModel
    var onSelect: (Budget) -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.budgets) { budget in
                    Button {
                        onSelect(budget)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            if budget.icon.count == 1 && budget.icon.unicodeScalars.first?.properties.isEmoji == true {
                                Text(budget.icon)
                                    .font(.title3)
                                    .frame(width: 36, height: 36)
                                    .background(budget.getColor().opacity(0.2))
                                    .cornerRadius(8)
                            } else {
                                Image(systemName: budget.icon)
                                    .foregroundColor(budget.getColor())
                                    .font(.title3)
                                    .frame(width: 36, height: 36)
                                    .background(budget.getColor().opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(budget.name)
                                    .foregroundColor(.primary)
                                
                                Text("₹\(budget.remainingAmount, specifier: "%.0f") available")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if viewModel.budgets.isEmpty {
                    ContentUnavailableView(
                        label: {
                            Label("No Budgets", systemImage: "folder")
                        },
                        description: {
                            Text("You need to create a budget first")
                        },
                        actions: {
                            Button("Create Budget") {
                                presentationMode.wrappedValue.dismiss()
                                // Show add budget sheet (would need additional callback for this)
                            }
                        }
                    )
                }
            }
            .navigationTitle("Select Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ExpensesView(viewModel: BudgetViewModel())
} 