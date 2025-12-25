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
                    Text("\(greeting), \(viewModel.currentUser?.name ?? "User")")
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
                    SummaryCard(title: "Total Budget", value: viewModel.totalBudget, iconName: "banknote.fill", color: .blue)
                    SummaryCard(title: "Total Spent", value: viewModel.totalSpent, iconName: "arrow.down.circle.fill", color: .red)
                }
                
                HStack(spacing: 16) {
                    SummaryCard(title: "Remaining", value: viewModel.totalRemaining, iconName: "arrow.up.circle.fill", color: .green)
                    SummaryCard(title: "Budgets", value: Double(viewModel.budgets.count), iconName: "folder.fill", color: .orange, isCount: true)
                }
                
                // Spending Chart
                SpendingChartView(budgets: viewModel.budgets)
                    .padding(.vertical, 4)
                
                // Budgets Section
                Text("Your Budgets")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
                
                // Budget List
                if viewModel.budgets.isEmpty {
                    EmptyBudgetView()
                } else {
                    VStack(spacing: 16) {
                        ForEach(viewModel.budgets) { budget in
                            NavigationLink(destination: BudgetDetailView(viewModel: viewModel, budget: binding(for: budget))) {
                                BudgetCardView(budget: budget)
                            }
                        }
                    }
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
                    Text("Account Balance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("₹\(Int(viewModel.currentUser?.currentBalance ?? 0))")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(dateFormatter.string(from: viewModel.currentUser?.balanceStartDate ?? Date()))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("₹\(Int(viewModel.currentUser?.monthlyStartBalance ?? 0))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.caption2)
                            Text("Edit")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    }
                    .padding(.top, 4)
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
                            viewModel.updateMonthlyBalance(amount: amount)
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
        }
    }
}

#Preview {
    let viewModel = BudgetViewModel()
    return MainTabView(viewModel: viewModel)
} 