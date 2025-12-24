import SwiftUI

struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BudgetViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Notifications")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // Placeholder for future implementation
                    VStack(spacing: 15) {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("No Notifications")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("You're all caught up!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let viewModel = BudgetViewModel()
    return NotificationsView(viewModel: viewModel)
}
