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
                    // Subtle background gradient
                    LinearGradient(
                        gradient: Gradient(colors: [Color(UIColor.systemBackground), Color(UIColor.systemBackground).opacity(0.95)]),
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
            // Style the tab bar with a subtle shadow
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
            
            // Add shadow
            appearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
            
            // Customize selected item appearance
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.normal.iconColor = .gray
            itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
            itemAppearance.selected.iconColor = UIColor.systemBlue
            itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
            
            appearance.stackedLayoutAppearance = itemAppearance
            appearance.inlineLayoutAppearance = itemAppearance
            appearance.compactInlineLayoutAppearance = itemAppearance
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
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
                    .frame(height: 320)
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
                        Label("Add", systemImage: "plus.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .tint(.blue.opacity(0.2))
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
        .background(Color(UIColor.systemGroupedBackground).opacity(0.5))
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