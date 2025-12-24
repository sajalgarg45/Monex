import Foundation

struct Expense: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var amount: Double
    var date: Date
    var note: String
    
    init(id: UUID = UUID(), title: String, amount: Double, date: Date = Date(), note: String = "") {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.note = note
    }
    
    // Sample expenses for preview
    static let sampleExpenses = [
        Expense(title: "Vegetables", amount: 2000, note: "Weekly grocery shopping"),
        Expense(title: "Milk and Dairy", amount: 1500, note: "Monthly dairy supply"),
        Expense(title: "Snacks", amount: 800, note: "Party snacks"),
    ]
} 