import SwiftUI
import Charts

struct DashboardView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @State private var showingAddBudget = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
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
                        .frame(height: 300)
                        .padding(.vertical)
                    
                    // Budgets Section
                    HStack {
                        Text("Your Budgets")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            showingAddBudget = true
                        } label: {
                            Label("Add", systemImage: "plus.circle.fill")
                                .font(.subheadline)
                        }
                    }
                    .padding(.top)
                    
                    // Budget List
                    if viewModel.budgets.isEmpty {
                        EmptyBudgetView()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(viewModel.budgets) { budget in
                                NavigationLink(destination: BudgetDetailView(viewModel: viewModel, budget: binding(for: budget))) {
                                    BudgetCardView(budget: budget)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.logout()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView(viewModel: viewModel)
            }
        }
    }
    
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

struct SummaryCard: View {
    let title: String
    let value: Double
    let iconName: String
    let color: Color
    var isCount: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            if isCount {
                Text("\(Int(value))")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            } else {
                Text("₹\(value, specifier: "%.0f")")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 2)
    }
}

struct SpendingChartView: View {
    let budgets: [Budget]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending Breakdown")
                .font(.title3)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                if #available(iOS 16.0, *) {
                    if budgets.filter({ $0.amount - $0.remainingAmount > 0 }).isEmpty {
                        // Empty state
                        VStack(spacing: 12) {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary.opacity(0.3))
                            
                            Text("No spending data yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                    } else {
                        Chart {
                            ForEach(budgets.filter({ $0.amount - $0.remainingAmount > 0 })) { budget in
                                SectorMark(
                                    angle: .value("Amount", budget.amount - budget.remainingAmount),
                                    innerRadius: .ratio(0.65),
                                    angularInset: 2
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            budget.getColor(),
                                            budget.getColor().opacity(0.7)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(4)
                            }
                        }
                        .frame(height: 180)
                        .chartBackground { chartProxy in
                            GeometryReader { geometry in
                                let frame = geometry[chartProxy.plotAreaFrame]
                                VStack(spacing: 4) {
                                    Text("Total")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("₹\(budgets.reduce(0) { $0 + ($1.amount - $1.remainingAmount) }, specifier: "%.0f")")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                                .position(x: frame.midX, y: frame.midY)
                            }
                        }
                    }
                } else {
                    // Fallback for iOS versions earlier than 16
                    Text("Chart requires iOS 16 or later")
                        .foregroundColor(.secondary)
                }
                
                // Legend
                if !budgets.filter({ $0.amount - $0.remainingAmount > 0 }).isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(budgets.filter({ $0.amount - $0.remainingAmount > 0 })) { budget in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                budget.getColor(),
                                                budget.getColor().opacity(0.7)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 14, height: 14)
                                
                                Text(budget.name)
                                    .font(.callout)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("₹\(budget.amount - budget.remainingAmount, specifier: "%.0f")")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 2)
        }
    }
}

struct BudgetCardView: View {
    let budget: Budget
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                budget.getColor().opacity(colorScheme == .dark ? 0.3 : 0.2),
                                budget.getColor().opacity(colorScheme == .dark ? 0.15 : 0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                if budget.icon.count == 1 && budget.icon.unicodeScalars.first?.properties.isEmoji == true {
                    Text(budget.icon)
                        .font(.system(size: 26))
                } else {
                    Image(systemName: budget.icon)
                        .foregroundColor(budget.getColor())
                        .font(.system(size: 24, weight: .semibold))
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(budget.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Budget - ₹\(budget.amount, specifier: "%.0f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("₹\(budget.remainingAmount, specifier: "%.0f") remaining")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        Capsule()
                            .fill(
                                colorScheme == .dark
                                ? Color.white.opacity(0.1)
                                : budget.getColor().opacity(0.15)
                            )
                            .frame(height: 8)
                        
                        // Progress fill with gradient
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        budget.getColor(),
                                        budget.getColor().opacity(0.7)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: max(8, min(CGFloat(1 - budget.spentPercentage) * geometry.size.width, geometry.size.width)),
                                height: 8
                            )
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: budget.spentPercentage)
                    }
                }
                .frame(height: 8)
                .padding(.top, 2)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Spent")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(Int(budget.spentPercentage * 100))%")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(budget.spentPercentage > 0.9 ? .red : budget.getColor())
            }
        }
        .padding()
        .cardStyle()
    }
}

struct EmptyBudgetView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(colorScheme == .dark ? 0.2 : 0.1),
                                Color.blue.opacity(colorScheme == .dark ? 0.1 : 0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.blue.opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text("No Budgets Yet")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Add a budget to start tracking your expenses")
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

struct ProgressBar: View {
    var progress: Double
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(color.opacity(0.3))
                
                Rectangle()
                    .frame(width: min(CGFloat(self.progress) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(color)
                    .animation(.linear, value: progress)
            }
        }
    }
}

#Preview {
    let viewModel = BudgetViewModel()
    viewModel.budgets = Budget.sampleBudgets
    return DashboardView(viewModel: viewModel)
} 
