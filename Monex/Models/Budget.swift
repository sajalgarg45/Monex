import Foundation
import SwiftUI

struct Budget: Identifiable, Codable {
    var id: UUID
    var name: String
    var amount: Double
    var icon: String
    var color: String
    var expenses: [Expense]
    var isMiscellaneous: Bool
    
    var remainingAmount: Double {
        return amount - expenses.reduce(0) { $0 + $1.amount }
    }
    
    var spentPercentage: Double {
        return amount > 0 ? (amount - remainingAmount) / amount : 0
    }
    
    var totalSpent: Double {
        return expenses.reduce(0) { $0 + $1.amount }
    }
    
    init(id: UUID = UUID(), name: String, amount: Double, icon: String, color: String, expenses: [Expense] = [], isMiscellaneous: Bool = false) {
        self.id = id
        self.name = name
        self.amount = amount
        self.icon = icon
        self.color = color
        self.expenses = expenses
        self.isMiscellaneous = isMiscellaneous
    }
    
    // Helper to get Color from stored string
    func getColor() -> Color {
        switch color {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "yellow": return .yellow
        default: return .blue
        }
    }
    
    // Sample budgets for preview
    static let sampleBudgets = [
        Budget(name: "Groceries", amount: 8000, icon: "cart.fill", color: "green"),
        Budget(name: "Rent", amount: 15000, icon: "house.fill", color: "blue"),
        Budget(name: "EMI", amount: 12000, icon: "creditcard.fill", color: "purple"),
        Budget(name: "School", amount: 5000, icon: "book.fill", color: "orange")
    ]
} 