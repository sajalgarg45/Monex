import Foundation
import SwiftUI

#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - Chat Message Model

struct ChatMessage: Identifiable {
    let id = UUID()
    var content: String
    let isUser: Bool
    let timestamp: Date
    
    init(content: String, isUser: Bool) {
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
    }
}

// MARK: - AI Availability State

enum AIAvailabilityState {
    case available
    case unavailable(String)
    case checking
}

// MARK: - MonexAI ViewModel

@MainActor
class MonexAIViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isResponding: Bool = false
    @Published var availabilityState: AIAvailabilityState = .checking
    
    private weak var budgetViewModel: BudgetViewModel?
    
    // Store session as Any? to avoid availability issues on stored properties
    private var _session: Any? = nil
    
    init(budgetViewModel: BudgetViewModel) {
        self.budgetViewModel = budgetViewModel
        checkAvailability()
    }
    
    // MARK: - Availability Check
    
    func checkAvailability() {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let model = SystemLanguageModel.default
            switch model.availability {
            case .available:
                availabilityState = .available
                initializeSession()
            case .unavailable(let reason):
                availabilityState = .unavailable(unavailableMessageText(reason))
            @unknown default:
                availabilityState = .unavailable("The AI model is unavailable for an unknown reason.")
            }
        } else {
            availabilityState = .unavailable("MonexAI requires iOS 26 or later. Please update your device.")
        }
        #else
        availabilityState = .unavailable("Foundation Models framework is not available on this platform. Requires iOS 26 or later.")
        #endif
    }
    
    // MARK: - Session Management
    
    private func initializeSession() {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let instructions = buildSystemInstructions()
            _session = LanguageModelSession(instructions: instructions)
        }
        #endif
    }
    
    private func buildSystemInstructions() -> String {
        var instruction = """
        You are MonexAI, a smart, friendly, and knowledgeable personal finance assistant built into the Monex expense tracking app. \
        You help users understand their spending habits, budgets, assets, loans, and overall financial health.
        
        Guidelines:
        - Always be helpful, concise, and encouraging.
        - When the user asks about their finances, base your answers on the financial data provided below.
        - If the user asks about something not covered by their data, provide general financial advice.
        - Use the Indian Rupee (₹) symbol for currency values.
        - Format numbers nicely (e.g., ₹12,500 instead of 12500).
        - When listing items, use bullet points or numbered lists for clarity.
        - Be proactive — offer tips or observations when relevant.
        
        """
        
        instruction += buildFinancialContext()
        return instruction
    }
    
    // MARK: - Financial Context Builder
    
    private func buildFinancialContext() -> String {
        guard let vm = budgetViewModel else {
            return "No financial data is currently available."
        }
        
        var context = "=== USER'S FINANCIAL DATA ===\n\n"
        
        // User info
        if let user = vm.currentUser {
            context += "USER: \(user.firstName) \(user.lastName)\n"
            context += "Monthly Starting Balance: ₹\(Int(user.monthlyStartBalance))\n"
            let currentBalance = user.monthlyStartBalance - vm.totalSpent
            context += "Current Balance: ₹\(Int(currentBalance))\n"
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, yyyy"
            context += "Balance Start Date: \(formatter.string(from: user.balanceStartDate))\n\n"
        }
        
        // Summary
        context += "--- SUMMARY ---\n"
        context += "Total Budget Allocated: ₹\(Int(vm.totalBudget))\n"
        context += "Total Amount Spent: ₹\(Int(vm.totalSpent))\n"
        context += "Total Remaining in Budgets: ₹\(Int(vm.totalRemaining))\n\n"
        
        // Budgets with expenses
        if !vm.budgets.isEmpty {
            context += "--- BUDGETS ---\n"
            for budget in vm.budgets {
                context += "• \(budget.name): Budget ₹\(Int(budget.amount)), Spent ₹\(Int(budget.totalSpent)), Remaining ₹\(Int(budget.remainingAmount)) (\(Int(budget.spentPercentage * 100))% used)\n"
                if !budget.expenses.isEmpty {
                    for expense in budget.expenses {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMM dd"
                        context += "    - \(expense.title): ₹\(Int(expense.amount)) on \(dateFormatter.string(from: expense.date))"
                        if !expense.note.isEmpty {
                            context += " (\(expense.note))"
                        }
                        context += "\n"
                    }
                }
            }
            context += "\n"
        }
        
        // Miscellaneous expenses
        if !vm.miscBudget.expenses.isEmpty {
            context += "--- MISCELLANEOUS EXPENSES (No budget limit) ---\n"
            for expense in vm.miscBudget.expenses {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd"
                context += "• \(expense.title): ₹\(Int(expense.amount)) on \(dateFormatter.string(from: expense.date))"
                if !expense.note.isEmpty {
                    context += " (\(expense.note))"
                }
                context += "\n"
            }
            context += "Miscellaneous Total Spent: ₹\(Int(vm.miscBudget.totalSpent))\n\n"
        }
        
        // Assets
        if !vm.assets.isEmpty {
            context += "--- ASSETS & INVESTMENTS ---\n"
            context += "Total Investments Value: ₹\(Int(vm.totalInvestments))\n"
            context += "Total Liabilities (Loans): ₹\(Int(vm.totalLiabilities))\n"
            context += "Total Insurance Coverage: ₹\(Int(vm.totalInsurance))\n"
            context += "Net Worth: ₹\(Int(vm.netWorth))\n\n"
            
            for asset in vm.assets {
                context += "• \(asset.name) [\(asset.type.rawValue)]: ₹\(Int(asset.amount))\n"
                if let loan = asset.loanDetails {
                    context += "    Loan: Total ₹\(Int(loan.totalLoanAmount)), EMI ₹\(Int(loan.monthlyEMI)), Remaining ₹\(Int(loan.remainingAmount)), Rate \(loan.interestRate)%\n"
                }
                if let fd = asset.fixedDepositDetails {
                    context += "    FD at \(fd.bankName): Principal ₹\(Int(fd.principalAmount)), Rate \(fd.interestRate)%\n"
                }
                if let mf = asset.mutualFundDetails {
                    context += "    MF: Lumpsum ₹\(Int(mf.lumpsum)), SIP ₹\(Int(mf.sipMonthly))/month, Current Value ₹\(Int(mf.currentValue))\n"
                }
                if let stock = asset.stockDetails {
                    context += "    Stock: \(stock.companyName), \(stock.numberOfShares) shares @ ₹\(Int(stock.pricePerShare))\n"
                }
                if let insurance = asset.insuranceDetails {
                    context += "    Insurance: Premium ₹\(Int(insurance.monthlyPremium))/month, Coverage ₹\(Int(insurance.coverageAmount))\n"
                }
            }
            context += "\n"
        }
        
        context += "=== END OF FINANCIAL DATA ==="
        return context
    }
    
    // MARK: - Send Message
    
    func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(content: trimmed, isUser: true)
        messages.append(userMessage)
        
        // Generate AI response
        Task {
            await generateResponse(for: trimmed)
        }
    }
    
    private func generateResponse(for prompt: String) async {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            guard let session = _session as? LanguageModelSession else {
                let errorMsg = ChatMessage(content: "AI session is not available. Please check that Apple Intelligence is enabled on your device.", isUser: false)
                messages.append(errorMsg)
                return
            }
            
            isResponding = true
            
            // Add placeholder for AI response
            let aiMessage = ChatMessage(content: "", isUser: false)
            messages.append(aiMessage)
            let messageIndex = messages.count - 1
            
            do {
                let stream = session.streamResponse(to: prompt)
                for try await snapshot in stream {
                    messages[messageIndex].content = snapshot.content
                }
            } catch {
                messages[messageIndex].content = "Sorry, I couldn't generate a response. Please try again.\n\nError: \(error.localizedDescription)"
            }
            
            isResponding = false
        } else {
            let errorMsg = ChatMessage(content: "MonexAI requires iOS 26 or later.", isUser: false)
            messages.append(errorMsg)
        }
        #else
        let errorMsg = ChatMessage(content: "Foundation Models is not available on this platform.", isUser: false)
        messages.append(errorMsg)
        #endif
    }
    
    // MARK: - Clear Chat
    
    func clearChat() {
        messages.removeAll()
        initializeSession()
    }
    
    // MARK: - Helpers
    
    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func unavailableMessageText(_ reason: SystemLanguageModel.Availability.UnavailableReason) -> String {
        switch reason {
        case .deviceNotEligible:
            return "This device doesn't support Apple Intelligence. MonexAI requires an iPhone 15 Pro or later."
        case .appleIntelligenceNotEnabled:
            return "Apple Intelligence is not enabled. Please go to Settings → Apple Intelligence & Siri to enable it."
        case .modelNotReady:
            return "The AI model is still downloading. Please wait a few minutes and try again."
        @unknown default:
            return "The AI model is currently unavailable. Please try again later."
        }
    }
    #endif
}
