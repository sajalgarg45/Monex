import SwiftUI

struct MainTabView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @State private var selectedTab = 0
    @State private var showingAddBudget = false
    @State private var showingNotifications = false
    
    var body: some View {
        // Main TabView with 4 tabs
        TabView(selection: $selectedTab) {
            // Dashboard tab
            NavigationView {
                ZStack {
                    // Background gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(UIColor.systemGroupedBackground),
                            Color(UIColor.systemGroupedBackground).opacity(0.8)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    DashboardContentView(viewModel: viewModel)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingNotifications = true
                        } label: {
                            Image(systemName: "bell.fill")
                        }
                    }
                }
                .sheet(isPresented: $showingAddBudget) {
                    AddBudgetView(viewModel: viewModel)
                }
                .sheet(isPresented: $showingNotifications) {
                    NotificationsView(viewModel: viewModel)
                }
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            .tag(0)
            
            // Budgets tab
            BudgetsView(viewModel: viewModel)
                .tabItem {
                    Label("Budgets", systemImage: "folder.fill")
                }
                .tag(1)
            
            // Expenses tab
            ExpensesView(viewModel: viewModel)
                .tabItem {
                    Label("Expenses", systemImage: "creditcard.fill")
                }
                .tag(2)
            
            // Profile tab
            ProfileView(viewModel: viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .onAppear {
            // Style the tab bar with glass effect and increased height
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.85)
            
            // Add shadow and blur
            appearance.shadowColor = UIColor.black.withAlphaComponent(0.15)
            
            // Customize selected item appearance with larger icons
            let itemAppearance = UITabBarItemAppearance()
            
            // Increase icon size
            itemAppearance.normal.iconColor = .systemGray
            itemAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.systemGray,
                .font: UIFont.systemFont(ofSize: 11, weight: .medium)
            ]
            
            itemAppearance.selected.iconColor = UIColor.systemBlue
            itemAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.systemBlue,
                .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
            ]
            
            // Apply larger size transform
            itemAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)
            itemAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 2)
            
            appearance.stackedLayoutAppearance = itemAppearance
            appearance.inlineLayoutAppearance = itemAppearance
            appearance.compactInlineLayoutAppearance = itemAppearance
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
            
            // Increase tab bar height
            UITabBar.appearance().layer.masksToBounds = false
            UITabBar.appearance().layer.shadowColor = UIColor.black.cgColor
            UITabBar.appearance().layer.shadowOpacity = 0.1
            UITabBar.appearance().layer.shadowOffset = CGSize(width: 0, height: -3)
            UITabBar.appearance().layer.shadowRadius = 12
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 10)
        }
    }
    
    // Helper to get binding for a budget
    func binding(for budget: Budget) -> Binding<Budget> {
        guard let index = viewModel.budgets.firstIndex(where: { $0.id == budget.id }) else {
            fatalError("Budget not found")
        }
        return Binding(
            get: { viewModel.budgets[index] },
            set: { viewModel.budgets[index] = $0 }
        )
    }
}

struct DashboardContentView: View {
    @ObservedObject var viewModel: BudgetViewModel
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<21:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                // Greeting Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(greeting), \(viewModel.currentUser?.firstName ?? "User")")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Let's track your spending\ntoday.")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
                
                // Monthly Balance Card
                MonthlyBalanceCard(viewModel: viewModel)
                
                // Summary Cards
                HStack(spacing: 16) {
                    SummaryCard(title: "Total Spent", value: viewModel.totalSpent, iconName: "arrow.down.circle.fill", color: .red)
                    SummaryCard(title: "Expenses", value: Double(totalExpensesCount(viewModel: viewModel)), iconName: "list.bullet.circle.fill", color: .orange, isCount: true)
                }
                
                // Spending Chart
                SpendingChartView(budgets: viewModel.budgets, miscBudget: viewModel.miscBudget)
                    .padding(.vertical, 4)
                
                // Miscellaneous Budget Section
                Text("Miscellaneous")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
                
                NavigationLink(destination: BudgetDetailView(viewModel: viewModel, budget: $viewModel.miscBudget)) {
                    MiscBudgetCardView(budget: viewModel.miscBudget)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(UIColor.systemGroupedBackground),
                    Color(UIColor.systemGroupedBackground).opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // Helper to get binding for a budget
    func binding(for budget: Budget) -> Binding<Budget> {
        guard let index = viewModel.budgets.firstIndex(where: { $0.id == budget.id }) else {
            fatalError("Budget not found")
        }
        return Binding(
            get: { viewModel.budgets[index] },
            set: { viewModel.budgets[index] = $0 }
        )
    }
}

// Helper function to get total expenses count
func totalExpensesCount(viewModel: BudgetViewModel) -> Int {
    let regularExpenses = viewModel.budgets.reduce(0) { $0 + $1.expenses.count }
    let miscExpenses = viewModel.miscBudget.expenses.count
    return regularExpenses + miscExpenses
}

struct MonthlyBalanceCard: View {
    @ObservedObject var viewModel: BudgetViewModel
    @State private var showingEditSheet = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.purple)
                        Text("Account Balance")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("₹\(Int((viewModel.currentUser?.monthlyStartBalance ?? 0) - viewModel.totalSpent))")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .frame(width: 32, height: 32)
                    }
                    
                    Text(dateFormatter.string(from: viewModel.currentUser?.balanceStartDate ?? Date()))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    
                    Text("₹\(Int(viewModel.currentUser?.monthlyStartBalance ?? 0))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .sheet(isPresented: $showingEditSheet) {
            EditBalanceSheet(viewModel: viewModel)
        }
    }
}

struct EditBalanceSheet: View {
    @ObservedObject var viewModel: BudgetViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var balanceText = ""
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Monthly Starting Balance")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Enter your account balance at the start of this month")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
                
                TextField("Amount", text: $balanceText)
                    .keyboardType(.numberPad)
                    .font(.system(size: 24, weight: .semibold))
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Start Date")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Edit Balance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let amount = Double(balanceText) {
                            viewModel.updateMonthlyBalance(amount: amount, startDate: selectedDate)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(balanceText.isEmpty)
                }
            }
        }
        .onAppear {
            balanceText = "\(Int(viewModel.currentUser?.monthlyStartBalance ?? 0))"
            selectedDate = viewModel.currentUser?.balanceStartDate ?? Date()
        }
    }
}

struct MiscBudgetCardView: View {
    let budget: Budget
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(red: 78/255, green: 205/255, blue: 196/255).opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: budget.icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 78/255, green: 205/255, blue: 196/255))
            }
            
            // Budget Info
            VStack(alignment: .leading, spacing: 6) {
                Text(budget.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("No limit")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount Spent
            VStack(alignment: .trailing, spacing: 4) {
                Text("Spent")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("₹\(Int(budget.totalSpent))")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    let viewModel = BudgetViewModel()
    return MainTabView(viewModel: viewModel)
} 