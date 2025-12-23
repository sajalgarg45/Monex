import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BudgetViewModel()
    
    var body: some View {
        MainTabView(viewModel: viewModel)
    }
}

#Preview {
    ContentView()
} 