import Foundation

struct User: Identifiable, Codable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var monthlyStartBalance: Double
    var currentBalance: Double
    var balanceStartDate: Date
    
    var name: String {
        "\(firstName) \(lastName)"
    }
    
    init(id: String, firstName: String, lastName: String, email: String, monthlyStartBalance: Double = 0, currentBalance: Double = 0, balanceStartDate: Date = Date()) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.monthlyStartBalance = monthlyStartBalance
        self.currentBalance = currentBalance
        self.balanceStartDate = balanceStartDate
    }
    
    // Mock user for testing
    static let mockUser = User(id: "1", firstName: "John", lastName: "Doe", email: "john@example.com")
} 