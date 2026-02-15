import Foundation
import Combine

class BudgetViewModel: ObservableObject {
    @Published var budgets: [Budget] = []
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var miscBudget: Budget
    @Published var assets: [Asset] = []
    
    private func savePath(for userId: String) -> URL {
        FileManager.documentsDirectory.appendingPathComponent("SavedBudgets_\(userId)")
    }
    
    private func miscBudgetPath(for userId: String) -> URL {
        FileManager.documentsDirectory.appendingPathComponent("MiscBudget_\(userId)")
    }
    
    private func assetsPath(for userId: String) -> URL {
        FileManager.documentsDirectory.appendingPathComponent("SavedAssets_\(userId)")
    }
    
    init() {
        miscBudget = Budget(name: "Miscellaneous", amount: 0, icon: "square.grid.2x2.fill", color: "gray", isMiscellaneous: true)
        checkLoginState()
    }
    
    private func checkLoginState() {
        if let savedUser = loadUserData() {
            isLoggedIn = true
            currentUser = savedUser
            loadData(for: savedUser.id)
            loadMiscBudget(for: savedUser.id)
            loadAssets(for: savedUser.id)
        }
    }
    
    // Login functionality (mock for now)
    func login() {
        isLoggedIn = true
        currentUser = User.mockUser
        
        // Don't load sample data by default - let user create their own budgets
    }
    
    func signup(firstName: String, lastName: String, email: String, password: String) {
        // Create new user
        let newUser = User(id: UUID().uuidString, firstName: firstName, lastName: lastName, email: email)
        
        // Save user data
        saveUserData(newUser)
        
        // Auto login after signup
        isLoggedIn = true
        currentUser = newUser
        
        // Initialize empty data for new user
        budgets = []
        miscBudget = Budget(name: "Miscellaneous", amount: 0, icon: "square.grid.2x2.fill", color: "gray", isMiscellaneous: true)
        assets = []
        saveData()
        saveMiscBudget()
        saveAssets()
    }
    
    func login(email: String, password: String) -> Bool {
        // Load saved user data
        if let savedUser = loadUserData() {
            // Verify email matches
            if savedUser.email.lowercased() == email.lowercased() {
                isLoggedIn = true
                currentUser = savedUser;                loadData(for: savedUser.id)
                loadMiscBudget(for: savedUser.id)
                loadAssets(for: savedUser.id);                return true
            }
        }
        return false
    }
    
    func logout() {
        saveData()
        saveMiscBudget()
        saveAssets()
        isLoggedIn = false
        currentUser = nil
        budgets = []
        assets = []
        miscBudget = Budget(name: "Miscellaneous", amount: 0, icon: "square.grid.2x2.fill", color: "gray", isMiscellaneous: true)
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
    
    // MARK: - Asset Management
    
    func addAsset(_ asset: Asset) {
        assets.append(asset)
        saveAssets()
    }
    
    func updateAsset(_ asset: Asset) {
        if let index = assets.firstIndex(where: { $0.id == asset.id }) {
            assets[index] = asset
            saveAssets()
        }
    }
    
    func deleteAsset(_ asset: Asset) {
        assets.removeAll { $0.id == asset.id }
        saveAssets()
    }
    
    func recordEMIPayment(for asset: Asset, amount: Double, date: Date = Date(), notes: String = "") {
        guard let index = assets.firstIndex(where: { $0.id == asset.id }),
              var loanDetails = assets[index].loanDetails else { return }
        
        // Create EMI payment record
        let payment = EMIPayment(amount: amount, paymentDate: date, notes: notes)
        loanDetails.emiPayments.append(payment)
        
        // Reduce remaining amount
        loanDetails.remainingAmount = max(0, loanDetails.remainingAmount - amount)
        
        // Update asset
        assets[index].loanDetails = loanDetails
        assets[index].amount = loanDetails.remainingAmount
        
        saveAssets()
    }
    
    var totalInvestments: Double {
        assets.filter { $0.category == .investments }.reduce(0) { $0 + $1.amount }
    }
    
    var totalLiabilities: Double {
        assets.filter { $0.category == .loans }.reduce(0) { $0 + $1.amount }
    }
    
    var totalInsurance: Double {
        assets.filter { $0.category == .insurance }.reduce(0) { $0 + $1.amount }
    }
    
    var netWorth: Double {
        totalInvestments - totalLiabilities
    }
    
    // MARK: - Persistence
    
    private func saveData() {
        guard let userId = currentUser?.id else { return }
        do {
            let data = try JSONEncoder().encode(budgets)
            try data.write(to: savePath(for: userId), options: [.atomic, .completeFileProtection])
        } catch {
            print("Failed to save budgets: \(error.localizedDescription)")
        }
    }
    
    private func loadData(for userId: String) {
        do {
            let data = try Data(contentsOf: savePath(for: userId))
            budgets = try JSONDecoder().decode([Budget].self, from: data)
        } catch {
            print("No saved budgets found: \(error.localizedDescription)")
            budgets = []
        }
    }
    
    private func saveMiscBudget() {
        guard let userId = currentUser?.id else { return }
        do {
            let data = try JSONEncoder().encode(miscBudget)
            try data.write(to: miscBudgetPath(for: userId), options: [.atomic, .completeFileProtection])
        } catch {
            print("Unable to save misc budget: \(error.localizedDescription)")
        }
    }
    
    private func loadMiscBudget(for userId: String) {
        do {
            let data = try Data(contentsOf: miscBudgetPath(for: userId))
            miscBudget = try JSONDecoder().decode(Budget.self, from: data)
        } catch {
            // Keep default misc budget if load fails
            miscBudget = Budget(name: "Miscellaneous", amount: 0, icon: "square.grid.2x2.fill", color: "gray", isMiscellaneous: true)
        }
    }
    
    private func saveAssets() {
        guard let userId = currentUser?.id else { return }
        do {
            let data = try JSONEncoder().encode(assets)
            try data.write(to: assetsPath(for: userId), options: [.atomic, .completeFileProtection])
        } catch {
            print("Failed to save assets: \(error.localizedDescription)")
        }
    }
    
    private func loadAssets(for userId: String) {
        do {
            let data = try Data(contentsOf: assetsPath(for: userId))
            assets = try JSONDecoder().decode([Asset].self, from: data)
        } catch {
            print("No saved assets found: \(error.localizedDescription)")
            assets = []
        }
    }
} 
