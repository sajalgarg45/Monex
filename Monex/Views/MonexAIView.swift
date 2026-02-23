import SwiftUI

struct MonexAIView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @StateObject private var aiViewModel: MonexAIViewModel
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool
    
    init(viewModel: BudgetViewModel) {
        self.viewModel = viewModel
        _aiViewModel = StateObject(wrappedValue: MonexAIViewModel(budgetViewModel: viewModel))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                switch aiViewModel.availabilityState {
                case .checking:
                    ProgressView("Checking AI availability...")
                        .font(.headline)
                    
                case .unavailable(let reason):
                    unavailableView(reason: reason)
                    
                case .available:
                    chatView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .font(.headline)
                        Text("MonexAI")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !aiViewModel.messages.isEmpty {
                        Button {
                            aiViewModel.clearChat()
                        } label: {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .foregroundStyle(.secondary)
                                .font(.title3)
                        }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - Chat View
    
    private var chatView: some View {
        VStack(spacing: 0) {
            if aiViewModel.messages.isEmpty {
                welcomeView
            } else {
                messagesListView
            }
            
            inputBar
        }
    }
    
    // MARK: - Welcome View
    
    private var welcomeView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)
                
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.15), .purple.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(spacing: 8) {
                    Text("MonexAI Assistant")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Your personal finance advisor powered by Apple Intelligence")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // On-device badge
                HStack(spacing: 6) {
                    Image(systemName: "lock.shield.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("100% on-device · Private & secure")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(20)
                
                // Suggestion cards
                VStack(alignment: .leading, spacing: 12) {
                    Text("Try asking:")
                        .font(.headline)
                        .padding(.horizontal, 4)
                    
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button {
                            sendSuggestion(suggestion)
                        } label: {
                            SuggestionCard(text: suggestion)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 8)
                
                Spacer(minLength: 20)
            }
            .padding()
        }
    }
    
    // MARK: - Messages List
    
    private var messagesListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(aiViewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    
                    // Typing indicator
                    if aiViewModel.isResponding {
                        if let lastMsg = aiViewModel.messages.last, !lastMsg.isUser, lastMsg.content.isEmpty {
                            TypingIndicator()
                                .id("typing")
                        }
                    }
                }
                .padding()
            }
            .onChange(of: aiViewModel.messages.count) { _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: aiViewModel.messages.last?.content) { _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.2)) {
            if let lastMessage = aiViewModel.messages.last {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    // MARK: - Input Bar
    
    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(alignment: .bottom, spacing: 12) {
                TextField("Ask about your finances...", text: $messageText, axis: .vertical)
                    .lineLimit(1...5)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(22)
                    .focused($isInputFocused)
                
                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(
                            LinearGradient(
                                colors: canSend ? [.blue, .purple] : [Color.gray.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .disabled(!canSend)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(UIColor.systemBackground))
        }
    }
    
    private var canSend: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !aiViewModel.isResponding
    }
    
    // MARK: - Unavailable View
    
    private func unavailableView(reason: String) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.brain")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 12) {
                Text("MonexAI Unavailable")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(reason)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button {
                aiViewModel.checkAvailability()
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .font(.headline)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(25)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Helpers
    
    private func sendMessage() {
        let text = messageText
        messageText = ""
        isInputFocused = false
        aiViewModel.sendMessage(text)
    }
    
    private func sendSuggestion(_ text: String) {
        aiViewModel.sendMessage(text)
    }
    
    private var suggestions: [String] {
        [
            "How much did I spend this month?",
            "What are my top spending categories?",
            "Give me a summary of my budget health",
            "How can I save more money?",
            "What's my net worth?"
        ]
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if message.isUser {
                Spacer(minLength: 50)
            } else {
                // AI avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .padding(.top, 2)
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content.isEmpty ? " " : message.content)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.isUser
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [.blue, .purple.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            : AnyShapeStyle(Color(UIColor.secondarySystemGroupedBackground))
                    )
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(20)
                    .cornerRadius(message.isUser ? 4 : 20, corners: message.isUser ? .bottomRight : .init())
                    .cornerRadius(message.isUser ? 20 : 4, corners: message.isUser ? .init() : .bottomLeft)
                
                Text(timeString(from: message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if !message.isUser {
                Spacer(minLength: 50)
            }
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 16))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.top, 2)
            
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.secondary.opacity(0.5))
                        .frame(width: 8, height: 8)
                        .offset(y: animationOffset == CGFloat(index) ? -4 : 0)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(20)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                    animationOffset = 2
                }
            }
            
            Spacer(minLength: 50)
        }
    }
}

// MARK: - Suggestion Card

struct SuggestionCard: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .font(.body)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "arrow.up.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

#Preview {
    let viewModel = BudgetViewModel()
    return MonexAIView(viewModel: viewModel)
}
