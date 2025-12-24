import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BudgetViewModel()
    
    var body: some View {
        if viewModel.isLoggedIn {
            MainTabView(viewModel: viewModel)
        } else {
            LoginView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
} 