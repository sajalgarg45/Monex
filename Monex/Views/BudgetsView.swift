import SwiftUI

struct BudgetsView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @State private var showingAddBudget = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Budget summary cards
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Budget Summary")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            SummaryCard(title: "Total Budget", value: viewModel.totalBudget, iconName: "banknote.fill", color: .blue)
                            SummaryCard(title: "Total Spent", value: viewModel.totalSpent, iconName: "arrow.down.circle.fill", color: .red)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Budgets Section
                    HStack {
                        Text("Your Budgets")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button {
                            showingAddBudget = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    ZStack {
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.blue.opacity(0.8),
                                                        Color.blue.opacity(0.6)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.6),
                                                        Color.white.opacity(0.2)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    }
                                )
                                .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Budget List
                    if viewModel.budgets.isEmpty {
                        EmptyBudgetView()
                            .padding(.horizontal)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(viewModel.budgets) { budget in
                                NavigationLink(destination: BudgetDetailView(viewModel: viewModel, budget: binding(for: budget))) {
                                    BudgetCardView(budget: budget)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
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
            .navigationTitle("Budgets")
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView(viewModel: viewModel)
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

#Preview {
    BudgetsView(viewModel: BudgetViewModel())
} 