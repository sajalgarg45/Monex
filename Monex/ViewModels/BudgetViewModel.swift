import Foundation
import Combine

class BudgetViewModel: ObservableObject {
    @Published var budgets: [Budget] = []
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var miscBudget: Budget
    
    private let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedBudgets")
    private let miscBudgetPath = FileManager.documentsDirectory.appendingPathComponent("MiscBudget")
    
    init() {
        miscBudget = Budget(name: "Miscellaneous", amount: 0, icon: "square.grid.2x2.fill", color: "gray", isMiscellaneous: true)
        loadData()
        loadMiscBudget()
        checkLoginState()
    }
    
    private func checkLoginState() {
        if let savedUser = loadUserData() {
            isLoggedIn = true
            currentUser = savedUser
        }
    }
    
    // Login functionality (mock for now)
    func login() {
        isLoggedIn = true
        currentUser = User.mockUser
        
        // Don't load sample data by default - let user create their own budgets
    }
    
    func signup(name: String, email: String, password: String) {
        // Create new user
        let newUser = User(id: UUID().uuidString, name: name, email: email)
        
        // Save user data
        saveUserData(newUser)
        
        // Auto login after signup
        isLoggedIn = true
        currentUser = newUser
    }
    
    func login(email: String, password: String) -> Bool {
        // Load saved user data
        if let savedUser = loadUserData() {
            // Verify email matches
            if savedUser.email.lowercased() == email.lowercased() {
                isLoggedIn = true
                currentUser = savedUser
                return true
            }
        }
        return false
    }
    
    func logout() {
        saveData()
        isLoggedIn = false
        currentUser = nil
    }
    
    func updateMonthlyBalance(amount: Double, startDate: Date = Date()) {
        guard var user = currentUser else { return }
        
        let calendar = Calendar.current
        user.balanceStartDate = calendar.startOfDay(for: startDate)
        user.monthlyStartBalance = amount
        user.currentBalance = amount - totalSpent
        
        currentUser = user
        saveUserData(user)
        objectWillChange.send()
    }
    
    func recalculateCurrentBalance() {
        guard var user = currentUser else { return }
        user.currentBalance = user.monthlyStartBalance - totalSpent
        currentUser = user
        saveUserData(user)
    }
    
    func updateCurrentBalance() {
        guard var user = currentUser else { return }
        user.currentBalance = user.monthlyStartBalance - totalSpent
        currentUser = user
        saveUserData(user)
    }
    
    // MARK: - User Data Persistence
    
    private let userSavePath = FileManager.documentsDirectory.appendingPathComponent("SavedUser")
    
    func saveUserData(_ user: User) {
        do {
            let data = try JSONEncoder().encode(user)
            try data.write(to: userSavePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("Failed to save user: \(error.localizedDescription)")
        }
    }
    
    private func loadUserData() -> User? {
        do {
            let data = try Data(contentsOf: userSavePath)
            return try JSONDecoder().decode(User.self, from: data)
        } catch {
            return nil
        }
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
        if budgetId == miscBudget.id {
            miscBudget.expenses.append(expense)
            saveMiscBudget()
        } else if let index = budgets.firstIndex(where: { $0.id == budgetId }) {
            budgets[index].expenses.append(expense)
            saveData()
        }
        recalculateCurrentBalance()
    }
    
    func deleteExpense(at indexSet: IndexSet, from budgetId: UUID) {
        if budgetId == miscBudget.id {
            miscBudget.expenses.remove(atOffsets: indexSet)
            saveMiscBudget()
        } else if let index = budgets.firstIndex(where: { $0.id == budgetId }) {
            budgets[index].expenses.remove(atOffsets: indexSet)
            saveData()
        }
        recalculateCurrentBalance()
    }
    
    func updateExpense(_ expense: Expense, in budgetId: UUID) {
        if budgetId == miscBudget.id {
            if let expenseIndex = miscBudget.expenses.firstIndex(where: { $0.id == expense.id }) {
                miscBudget.expenses[expenseIndex] = expense
                saveMiscBudget()
            }
        } else if let budgetIndex = budgets.firstIndex(where: { $0.id == budgetId }),
           let expenseIndex = budgets[budgetIndex].expenses.firstIndex(where: { $0.id == expense.id }) {
            budgets[budgetIndex].expenses[expenseIndex] = expense
            saveData()
        }
        recalculateCurrentBalance()
    }
    
    // MARK: - Data Summary
    
    var totalBudget: Double {
        budgets.reduce(0) { $0 + $1.amount }
    }
    
    var totalSpent: Double {
        let regularSpent = budgets.reduce(0) { $0 + ($1.amount - $1.remainingAmount) }
        let miscSpent = miscBudget.totalSpent
        return regularSpent + miscSpent
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
    
    private func saveMiscBudget() {
        do {
            let data = try JSONEncoder().encode(miscBudget)
            try data.write(to: miscBudgetPath, options: [.atomic, .completeFileProtection])
        } catch {
            print("Unable to save misc budget: \(error.localizedDescription)")
        }
    }
    
    private func loadMiscBudget() {
        do {
            let data = try Data(contentsOf: miscBudgetPath)
            miscBudget = try JSONDecoder().decode(Budget.self, from: data)
        } catch {
            // Keep default misc budget if load fails
        }
    }
} 