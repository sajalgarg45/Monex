import Foundation

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var monthlyStartBalance: Double
    var currentBalance: Double
    var balanceStartDate: Date
    
    init(id: String, name: String, email: String, monthlyStartBalance: Double = 0, currentBalance: Double = 0, balanceStartDate: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.monthlyStartBalance = monthlyStartBalance
        self.currentBalance = currentBalance
        self.balanceStartDate = balanceStartDate
    }
    
    // Mock user for testing
    static let mockUser = User(id: "1", name: "John Doe", email: "john@example.com")
} 