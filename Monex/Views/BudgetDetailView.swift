import SwiftUI
import Charts

struct BudgetDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BudgetViewModel
    @Binding var budget: Budget
    @State private var showingAddExpense = false
    @State private var showingEditBudget = false
    @State private var showingDeleteAlert = false
    @State private var showingEditExpense = false
    @State private var selectedExpense: Expense?
    @State private var showingDeleteExpenseAlert = false
    @State private var expenseToDelete: Expense?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Budget Info Card
                BudgetInfoCard(budget: budget)
                
                // Expenses over time chart
                if !budget.expenses.isEmpty {
                    if #available(iOS 16.0, *) {
                        ExpenseChart(expenses: budget.expenses)
                            .padding()
                            .cardStyle()
                    }
                }
                
                // Expenses Section
                HStack {
                    Text("Expenses")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        showingAddExpense = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
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
                                // Show delete confirmation
                                expenseToDelete = expense
                                showingDeleteExpenseAlert = true
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
                if !budget.isMiscellaneous {
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
                    presentationMode.wrappedValue.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.deleteBudget(at: IndexSet(integer: index))
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this budget? All expenses will be lost.")
        }
        .alert("Delete Expense", isPresented: $showingDeleteExpenseAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let expense = expenseToDelete,
                   let index = budget.expenses.firstIndex(where: { $0.id == expense.id }) {
                    budget.expenses.remove(at: index)
                    viewModel.updateBudget(budget)
                }
            }
        } message: {
            Text("Are you sure you want to delete this expense?")
        }
    }
}

struct BudgetInfoCard: View {
    let budget: Budget
    @Environment(\.colorScheme) var colorScheme
    
    var budgetColor: Color {
        if budget.isMiscellaneous {
            return Color(red: 78/255, green: 205/255, blue: 196/255)
        }
        return budget.getColor()
    }
    
    var body: some View {
        VStack(spacing: 18) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    budgetColor.opacity(colorScheme == .dark ? 0.3 : 0.2),
                                    budgetColor.opacity(colorScheme == .dark ? 0.15 : 0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                    
                    if budget.icon.count == 1 && budget.icon.unicodeScalars.first?.properties.isEmoji == true {
                        Text(budget.icon)
                            .font(.system(size: 32))
                    } else {
                        Image(systemName: budget.icon)
                            .foregroundColor(budgetColor)
                            .font(.system(size: 30, weight: .semibold))
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(budget.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    if !budget.isMiscellaneous {
                        Text("Budget: ₹\(budget.amount, specifier: "%.0f")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text(budget.isMiscellaneous ? "Spent" : "Remaining")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text("₹\(budget.isMiscellaneous ? budget.totalSpent : budget.remainingAmount, specifier: "%.0f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(budget.isMiscellaneous ? .primary : (budget.remainingAmount < budget.amount * 0.2 ? .red : .primary))
                        .frame(minWidth: 100, alignment: .trailing)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
            
            // Progress bar - only for non-miscellaneous budgets
            if !budget.isMiscellaneous {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Spent: ₹\(budget.amount - budget.remainingAmount, specifier: "%.0f")")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(budget.spentPercentage * 100))%")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track
                            Capsule()
                                .fill(
                                    colorScheme == .dark
                                    ? Color.white.opacity(0.1)
                                    : budgetColor.opacity(0.15)
                                )
                                .frame(height: 10)
                            
                            // Progress fill with gradient
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            budgetColor,
                                            budgetColor.opacity(0.7)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: min(CGFloat(budget.spentPercentage) * geometry.size.width, geometry.size.width),
                                    height: 10
                                )
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: budget.spentPercentage)
                        }
                    }
                    .frame(height: 10)
                }
            }
        }
        .padding()
        .cardStyle()
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
                .fontWeight(.semibold)
            
            Chart {
                ForEach(sortedExpenses, id: \.id) { expense in
                    LineMark(
                        x: .value("Date", expense.date),
                        y: .value("Amount", expense.amount)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                    
                    PointMark(
                        x: .value("Date", expense.date),
                        y: .value("Amount", expense.amount)
                    )
                    .foregroundStyle(.blue)
                    .symbol {
                        Circle()
                            .fill(.blue)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                            )
                    }
                    
                    AreaMark(
                        x: .value("Date", expense.date),
                        y: .value("Amount", expense.amount)
                    )
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.blue.opacity(0.2), .blue.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    let onEdit: () -> Void
    let onDelete: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
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
        .cardStyle()
    }
}

struct EmptyExpenseView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.green.opacity(colorScheme == .dark ? 0.2 : 0.1),
                                Color.green.opacity(colorScheme == .dark ? 0.1 : 0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "dollarsign.square.fill")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.green.opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text("No Expenses Yet")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Add an expense to start tracking your spending in this budget")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .cardStyle()
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
