import SwiftUI

struct MainTabView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @State private var selectedTab = 0
    
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
                        .navigationTitle("Dashboard")
                }
            }
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
    @State private var showingAddBudget = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
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
                HStack {
                    Text("Your Budgets")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        showingAddBudget = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Add")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .primaryButton(color: .blue)
                    }
                }
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
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView(viewModel: viewModel)
            }
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

#Preview {
    let viewModel = BudgetViewModel()
    return MainTabView(viewModel: viewModel)
} 