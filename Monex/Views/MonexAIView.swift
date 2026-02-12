import SwiftUI

struct MonexAIView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @State private var messageText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat area
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .padding()
                            
                            Text("Monex AI Assistant")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Your personal finance advisor")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                        
                        // Suggestion cards
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Try asking:")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(suggestions, id: \.self) { suggestion in
                                SuggestionCard(text: suggestion)
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding()
                }
                
                // Input area
                HStack(spacing: 12) {
                    TextField("Ask me anything about your finances...", text: $messageText)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(22)
                    
                    Button(action: {
                        // Handle send message
                        messageText = ""
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: messageText.isEmpty ? [.gray] : [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
    
    private var suggestions: [String] {
        [
            "How much did I spend this month?",
            "What are my top spending categories?",
            "How can I save more money?",
            "Show me my budget summary"
        ]
    }
}

struct SuggestionCard: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundColor(.blue)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

#Preview {
    let viewModel = BudgetViewModel()
    return MonexAIView(viewModel: viewModel)
}
