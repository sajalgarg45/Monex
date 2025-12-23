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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 20))
                        .foregroundStyle(color)
                }
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if isCount {
                Text("\(Int(value))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            } else {
                Text("₹\(value, specifier: "%.0f")")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

struct SpendingChartView: View {
    let budgets: [Budget]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Breakdown")
                .font(.headline)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(budgets) { budget in
                        SectorMark(
                            angle: .value("Amount", budget.amount - budget.remainingAmount > 0 ? budget.amount - budget.remainingAmount : 0.1),
                            innerRadius: .ratio(0.618),
                            angularInset: 1.5
                        )
                        .foregroundStyle(budget.getColor())
                        .cornerRadius(5)
                        .annotation(position: .overlay) {
                            Text(budget.name)
                                .font(.caption)
                                .foregroundColor(.white)
                                .fixedSize()
                                .opacity(budget.spentPercentage > 0.1 ? 1 : 0)
                        }
                    }
                }
                .frame(height: 150)
            } else {
                // Fallback for iOS versions earlier than 16
                Text("Chart requires iOS 16 or later")
                    .foregroundColor(.secondary)
            }
            
            // Legend
            VStack(alignment: .leading, spacing: 10) {
                ForEach(budgets) { budget in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(budget.getColor())
                            .frame(width: 12, height: 12)
                        
                        Text(budget.name)
                            .font(.callout)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("₹\(budget.amount - budget.remainingAmount, specifier: "%.0f")")
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

struct BudgetCardView: View {
    let budget: Budget
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(budget.getColor().opacity(0.15))
                    .frame(width: 50, height: 50)
                if budget.icon.count == 1 && budget.icon.unicodeScalars.first?.properties.isEmoji == true {
                    Text(budget.icon)
                        .font(.system(size: 22))
                } else {
                    Image(systemName: budget.icon)
                        .foregroundColor(budget.getColor())
                        .font(.system(size: 22, weight: .medium))
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(budget.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("₹\(budget.remainingAmount, specifier: "%.0f") of ₹\(budget.amount, specifier: "%.0f") remaining")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ProgressBar(progress: 1 - budget.spentPercentage, color: budget.getColor())
                    .frame(height: 6)
                    .clipShape(Capsule())
                    .padding(.top, 4)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(budget.spentPercentage * 100))%")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(budget.spentPercentage > 0.9 ? .red : budget.getColor())
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct EmptyBudgetView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard.fill")
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("No Budgets Yet")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Add a budget to start tracking your expenses")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                
            Button {
                // This would be connected to showing the add budget sheet
            } label: {
                Text("Add Budget")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
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
