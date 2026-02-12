import Foundation

struct Asset: Identifiable, Codable {
    var id = UUID()
    var name: String
    var amount: Double
    var type: AssetType
    var category: AssetCategory
    var notes: String
    var dateAdded: Date
    
    enum AssetType: String, Codable, CaseIterable {
        case mutualFunds = "Mutual Funds"
        case stocks = "Stocks"
        case gold = "Gold"
        case fixedDeposit = "Fixed Deposit"
        case homeLoan = "Home Loan"
        case carLoan = "Car Loan"
        case lic = "LIC"
        
        var icon: String {
            switch self {
            case .mutualFunds: return "chart.pie.fill"
            case .stocks: return "chart.line.uptrend.xyaxis"
            case .gold: return "crown.fill"
            case .fixedDeposit: return "building.columns.fill"
            case .homeLoan: return "house.fill"
            case .carLoan: return "car.fill"
            case .lic: return "shield.fill"
            }
        }
        
        var color: String {
            switch self {
            case .mutualFunds: return "blue"
            case .stocks: return "green"
            case .gold: return "yellow"
            case .fixedDeposit: return "purple"
            case .homeLoan: return "orange"
            case .carLoan: return "red"
            case .lic: return "cyan"
            }
        }
    }
    
    enum AssetCategory: String, Codable, CaseIterable {
        case investments = "Investments"
        case liabilities = "Liabilities"
        case insurance = "Insurance"
        
        var icon: String {
            switch self {
            case .investments: return "arrow.up.right.circle.fill"
            case .liabilities: return "arrow.down.right.circle.fill"
            case .insurance: return "shield.checkered"
            }
        }
    }
}
