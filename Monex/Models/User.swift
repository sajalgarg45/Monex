import Foundation

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    
    // Mock user for testing
    static let mockUser = User(id: "1", name: "John Doe", email: "john@example.com")
} 