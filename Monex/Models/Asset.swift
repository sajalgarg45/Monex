import Foundation

struct Asset: Identifiable, Codable {
    var id = UUID()
    var name: String
    var amount: Double
    var type: AssetType
    var category: AssetCategory
    var notes: String
    var dateAdded: Date
    
    // Investment specific fields
    var mutualFundDetails: MutualFundDetails?
    var stockDetails: StockDetails?
    var goldDetails: GoldDetails?
    var fixedDepositDetails: FixedDepositDetails?
    
    // Loan specific fields
    var loanDetails: LoanDetails?
    
    // Insurance specific fields
    var insuranceDetails: InsuranceDetails?
    
    enum AssetType: String, Codable, CaseIterable {
        case mutualFunds = "Mutual Funds"
        case stocks = "Stocks"
        case gold = "Gold/Silver"
        case fixedDeposit = "Fixed Deposit"
        case homeLoan = "Home Loan"
        case carLoan = "Car Loan"
        case educationLoan = "Education Loan"
        case otherLoan = "Other Loan"
        case healthInsurance = "Health Insurance"
        case lifeInsurance = "Life Insurance"
        case lic = "LIC"
        
        var icon: String {
            switch self {
            case .mutualFunds: return "chart.pie.fill"
            case .stocks: return "chart.line.uptrend.xyaxis"
            case .gold: return "crown.fill"
            case .fixedDeposit: return "building.columns.fill"
            case .homeLoan: return "house.fill"
            case .carLoan: return "car.fill"
            case .educationLoan: return "book.fill"
            case .otherLoan: return "creditcard.fill"
            case .healthInsurance: return "cross.case.fill"
            case .lifeInsurance: return "heart.fill"
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
            case .educationLoan: return "indigo"
            case .otherLoan: return "gray"
            case .healthInsurance: return "cyan"
            case .lifeInsurance: return "pink"
            case .lic: return "teal"
            }
        }
    }
    
    enum AssetCategory: String, Codable, CaseIterable {
        case investments = "Investments"
        case loans = "Loans"
        case insurance = "Insurance"
        
        var icon: String {
            switch self {
            case .investments: return "arrow.up.right.circle.fill"
            case .loans: return "arrow.down.right.circle.fill"
            case .insurance: return "shield.checkered"
            }
        }
    }
}

// Investment Details Structures
struct MutualFundDetails: Codable {
    var lumpsum: Double  // One-time investment
    var sipMonthly: Double  // Monthly SIP amount
    var sipStartDate: Date?
    var currentValue: Double
}

struct StockDetails: Codable {
    var companyName: String
    var numberOfShares: Int
    var pricePerShare: Double
    var purchaseDate: Date
}

struct GoldDetails: Codable {
    var weightInGrams: Double
    var pricePerGram: Double
    var metalType: String  // "Gold" or "Silver"
}

struct FixedDepositDetails: Codable {
    var bankName: String
    var depositDate: Date
    var maturityDate: Date
    var interestRate: Double
    var principalAmount: Double
}

// Loan Details Structure
struct LoanDetails: Codable {
    var totalLoanAmount: Double
    var monthlyEMI: Double
    var remainingAmount: Double
    var startDate: Date
    var interestRate: Double
    var tenure: Int  // in months
}

// Insurance Details Structure
struct InsuranceDetails: Codable {
    var monthlyPremium: Double
    var coverageAmount: Double
    var startDate: Date
    var policyNumber: String
}
