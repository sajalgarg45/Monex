import SwiftUI
import Charts

struct BudgetDetailView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @Binding var budget: Budget
    @State private var showingAddExpense = false
    @State private var showingEditBudget = false
    @State private var showingDeleteAlert = false
    @State private var showingEditExpense = false
    @State private var selectedExpense: Expense?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Budget Info Card
                BudgetInfoCard(budget: budget)
                
                // Expenses over time chart
                if !budget.expenses.isEmpty {
                    if #available(iOS 16.0, *) {
                        ExpenseChart(expenses: budget.expenses)
                            .frame(height: 200)
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                
                // Expenses Section
                HStack {
                    Text("Expenses")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button {
                        showingAddExpense = true
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                            .font(.subheadline)
                    }
                }
                .padding(.top)
                
                // Expenses List
                if budget.expenses.isEmpty {
                    EmptyExpenseView()
                } else {
                    VStack(spacing: 12) {
                        ForEach(budget.expenses.sorted(by: { $0.date > $1.date })) { expense in
                            ExpenseRowView(expense: expense) {
                                // Edit expense
                                selectedExpense = expense
                                showingEditExpense = true
                            } onDelete: {
                                // Delete expense
                                if let index = budget.expenses.firstIndex(where: { $0.id == expense.id }) {
                                    budget.expenses.remove(at: index)
                                    viewModel.updateBudget(budget)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(budget.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingEditBudget = true
                    } label: {
                        Label("Edit Budget", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Budget", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(viewModel: viewModel, budget: $budget)
        }
        .sheet(isPresented: $showingEditBudget) {
            EditBudgetView(viewModel: viewModel, budget: $budget)
        }
        .sheet(isPresented: $showingEditExpense) {
            if let expense = selectedExpense {
                EditExpenseView(viewModel: viewModel, budget: $budget, expense: expense)
            }
        }
        .alert("Delete Budget", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let index = viewModel.budgets.firstIndex(where: { $0.id == budget.id }) {
                    viewModel.deleteBudget(at: IndexSet(integer: index))
                }
            }
        } message: {
            Text("Are you sure you want to delete this budget? All expenses will be lost.")
        }
    }
}

struct BudgetInfoCard: View {
    let budget: Budget
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                if budget.icon.count == 1 && budget.icon.unicodeScalars.first?.properties.isEmoji == true {
                    Text(budget.icon)
                        .font(.largeTitle)
                        .frame(width: 60, height: 60)
                        .background(budget.getColor().opacity(0.2))
                        .cornerRadius(15)
                } else {
                    Image(systemName: budget.icon)
                        .foregroundColor(budget.getColor())
                        .font(.largeTitle)
                        .frame(width: 60, height: 60)
                        .background(budget.getColor().opacity(0.2))
                        .cornerRadius(15)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.name)
                        .font(.headline)
                    
                    Text("Budget: ₹\(budget.amount, specifier: "%.0f")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("₹\(budget.remainingAmount, specifier: "%.0f")")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(budget.remainingAmount < budget.amount * 0.2 ? .red : .primary)
                }
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Spent: ₹\(budget.amount - budget.remainingAmount, specifier: "%.0f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(budget.spentPercentage * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                ProgressBar(progress: budget.spentPercentage, color: budget.getColor())
                    .frame(height: 8)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// ExpenseChart without @available wrapper - availability check moved to usage
struct ExpenseChart: View {
    let expenses: [Expense]
    
    // Sort expenses by date for the chart (oldest first)
    private var sortedExpenses: [Expense] {
        expenses.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Expenses Over Time")
                .font(.headline)
            
            Chart {
                ForEach(sortedExpenses, id: \.id) { expense in
                    LineMark(
                        x: .value("Date", expense.date),
                        y: .value("Amount", expense.amount)
                    )
                    .foregroundStyle(.blue)
                    .symbol {
                        Circle()
                            .fill(.blue)
                            .frame(width: 8, height: 8)
                    }
                    
                    AreaMark(
                        x: .value("Date", expense.date),
                        y: .value("Amount", expense.amount)
                    )
                    .foregroundStyle(
                        .linearGradient(colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                                        startPoint: .top,
                                        endPoint: .bottom)
                    )
                }
            }
        }
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(expense.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !expense.note.isEmpty {
                    Text(expense.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text("₹\(expense.amount, specifier: "%.0f")")
                .font(.subheadline)
                .fontWeight(.bold)
            
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
    }
}

struct EmptyExpenseView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "dollarsign.square.fill")
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No Expenses Yet")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Add an expense to start tracking your spending in this budget")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        let viewModel = BudgetViewModel()
        var budget = Budget.sampleBudgets[0]
        budget.expenses = Expense.sampleExpenses
        return BudgetDetailView(viewModel: viewModel, budget: .constant(budget))
    }
}
