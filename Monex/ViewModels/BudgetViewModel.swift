import Foundation
import Combine

class BudgetViewModel: ObservableObject {
    @Published var budgets: [Budget] = []
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    
    private let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedBudgets")
    
    init() {
        loadData()
    }
    
    // Login functionality (mock for now)
    func login() {
        isLoggedIn = true
        currentUser = User.mockUser
        
        // Don't load sample data by default - let user create their own budgets
    }
    
    func logout() {
        saveData()
        isLoggedIn = false
        currentUser = nil
    }
    
    // MARK: - Budget Management
    
    func addBudget(_ budget: Budget) {
        budgets.append(budget)
        saveData()
    }
    
    func updateBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
            saveData()
        }
    }
    
    func deleteBudget(at indexSet: IndexSet) {
        budgets.remove(atOffsets: indexSet)
        saveData()
    }
    
    // MARK: - Expense Management
    
    func addExpense(_ expense: Expense, to budgetId: UUID) {
        if let index = budgets.firstIndex(where: { $0.id == budgetId }) {
            budgets[index].expenses.append(expense)
            saveData()
        }
    }
    
    func deleteExpense(at indexSet: IndexSet, from budgetId: UUID) {
        if let index = budgets.firstIndex(where: { $0.id == budgetId }) {
            budgets[index].expenses.remove(atOffsets: indexSet)
            saveData()
        }
    }
    
    func updateExpense(_ expense: Expense, in budgetId: UUID) {
        if let budgetIndex = budgets.firstIndex(where: { $0.id == budgetId }),
           let expenseIndex = budgets[budgetIndex].expenses.firstIndex(where: { $0.id == expense.id }) {
            budgets[budgetIndex].expenses[expenseIndex] = expense
            saveData()
        }
    }
    
    // MARK: - Data Summary
    
    var totalBudget: Double {
        budgets.reduce(0) { $0 + $1.amount }
    }
    
    var totalSpent: Double {
        budgets.reduce(0) { $0 + ($1.amount - $1.remainingAmount) }
    }
    
    var totalRemaining: Double {
        budgets.reduce(0) { $0 + $1.remainingAmount }
    }
    
    // MARK: - Persistence
    
    private func saveData() {
        do {
            let data = try JSONEncoder().encode(budgets)
            try data.write(to: savePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("Failed to save budgets: \(error.localizedDescription)")
        }
    }
    
    private func loadData() {
        do {
            let data = try Data(contentsOf: savePath)
            budgets = try JSONDecoder().decode([Budget].self, from: data)
        } catch {
            print("No saved budgets found: \(error.localizedDescription)")
            budgets = []
        }
    }
} 