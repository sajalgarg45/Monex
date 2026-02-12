import SwiftUI

struct AssetFormView: View {
    let category: Asset.AssetCategory
    let type: Asset.AssetType
    @ObservedObject var viewModel: BudgetViewModel
    let onBack: () -> Void
    let onSave: () -> Void
    
    @State private var assetName = ""
    @State private var notes = ""
    
    // Mutual Fund fields
    @State private var lumpsumAmount = ""
    @State private var sipMonthly = ""
    @State private var sipStartDate = Date()
    @State private var currentValue = ""
    
    // Stock fields
    @State private var companyName = ""
    @State private var numberOfShares = ""
    @State private var pricePerShare = ""
    @State private var purchaseDate = Date()
    
    // Gold fields
    @State private var metalType = "Gold"
    @State private var weightInGrams = ""
    @State private var pricePerGram = ""
    
    // FD fields
    @State private var bankName = ""
    @State private var principalAmount = ""
    @State private var interestRate = ""
    @State private var depositDate = Date()
    @State private var maturityDate = Date()
    
    // Loan fields
    @State private var totalLoanAmount = ""
    @State private var monthlyEMI = ""
    @State private var loanInterestRate = ""
    @State private var tenure = ""
    @State private var loanStartDate = Date()
    
    // Insurance fields
    @State private var monthlyPremium = ""
    @State private var coverageAmount = ""
    @State private var policyNumber = ""
    @State private var insuranceStartDate = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text(type.rawValue)
                    .font(.headline)
                
                Spacer()
                
                Button("Save") {
                    saveAsset()
                }
                .fontWeight(.semibold)
                .disabled(!isFormValid)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            Divider()
            
            Form {
                Section(header: Text("Basic Details")) {
                    TextField("Name", text: $assetName)
                }
                
                formContent
                
                Section(header: Text("Notes (Optional)")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private var formContent: some View {
        switch type {
        case .mutualFunds:
            mutualFundForm
        case .stocks:
            stockForm
        case .gold:
            goldForm
        case .fixedDeposit:
            fixedDepositForm
        case .homeLoan, .carLoan, .educationLoan, .otherLoan:
            loanForm
        case .healthInsurance, .lifeInsurance, .lic:
            insuranceForm
        }
    }
    
    private var mutualFundForm: some View {
        Section(header: Text("Investment Details")) {
            TextField("Lumpsum Investment (₹)", text: $lumpsumAmount)
                .keyboardType(.numberPad)
            
            TextField("Monthly SIP Amount (₹)", text: $sipMonthly)
                .keyboardType(.numberPad)
            
            DatePicker("SIP Start Date", selection: $sipStartDate, displayedComponents: .date)
            
            TextField("Current Value (₹)", text: $currentValue)
                .keyboardType(.numberPad)
        }
    }
    
    private var stockForm: some View {
        Section(header: Text("Stock Details")) {
            TextField("Company Name", text: $companyName)
            
            TextField("Number of Shares", text: $numberOfShares)
                .keyboardType(.numberPad)
            
            TextField("Price per Share (₹)", text: $pricePerShare)
                .keyboardType(.decimalPad)
            
            DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)
        }
    }
    
    private var goldForm: some View {
        Section(header: Text("Metal Details")) {
            Picker("Metal Type", selection: $metalType) {
                Text("Gold").tag("Gold")
                Text("Silver").tag("Silver")
            }
            .pickerStyle(.segmented)
            
            TextField("Weight (grams)", text: $weightInGrams)
                .keyboardType(.decimalPad)
            
            TextField("Price per Gram (₹)", text: $pricePerGram)
                .keyboardType(.decimalPad)
        }
    }
    
    private var fixedDepositForm: some View {
        Section(header: Text("Fixed Deposit Details")) {
            TextField("Bank Name", text: $bankName)
            
            TextField("Principal Amount (₹)", text: $principalAmount)
                .keyboardType(.numberPad)
            
            TextField("Interest Rate (%)", text: $interestRate)
                .keyboardType(.decimalPad)
            
            DatePicker("Deposit Date", selection: $depositDate, displayedComponents: .date)
            
            DatePicker("Maturity Date", selection: $maturityDate, displayedComponents: .date)
        }
    }
    
    private var loanForm: some View {
        Section(header: Text("Loan Details")) {
            TextField("Total Loan Amount (₹)", text: $totalLoanAmount)
                .keyboardType(.numberPad)
            
            TextField("Monthly EMI (₹)", text: $monthlyEMI)
                .keyboardType(.numberPad)
            
            TextField("Interest Rate (%)", text: $loanInterestRate)
                .keyboardType(.decimalPad)
            
            TextField("Tenure (months)", text: $tenure)
                .keyboardType(.numberPad)
            
            DatePicker("Loan Start Date", selection: $loanStartDate, displayedComponents: .date)
        }
    }
    
    private var insuranceForm: some View {
        Section(header: Text("Insurance Details")) {
            TextField("Monthly Premium (₹)", text: $monthlyPremium)
                .keyboardType(.numberPad)
            
            TextField("Coverage Amount (₹)", text: $coverageAmount)
                .keyboardType(.numberPad)
            
            TextField("Policy Number", text: $policyNumber)
            
            DatePicker("Policy Start Date", selection: $insuranceStartDate, displayedComponents: .date)
        }
    }
    
    private var isFormValid: Bool {
        guard !assetName.isEmpty else { return false }
        
        switch type {
        case .mutualFunds:
            return !currentValue.isEmpty
        case .stocks:
            return !companyName.isEmpty && !numberOfShares.isEmpty && !pricePerShare.isEmpty
        case .gold:
            return !weightInGrams.isEmpty && !pricePerGram.isEmpty
        case .fixedDeposit:
            return !bankName.isEmpty && !principalAmount.isEmpty && !interestRate.isEmpty
        case .homeLoan, .carLoan, .educationLoan, .otherLoan:
            return !totalLoanAmount.isEmpty && !monthlyEMI.isEmpty
        case .healthInsurance, .lifeInsurance, .lic:
            return !monthlyPremium.isEmpty && !coverageAmount.isEmpty && !policyNumber.isEmpty
        }
    }
    
    private func saveAsset() {
        var asset: Asset
        
        switch type {
        case .mutualFunds:
            let lumpsum = Double(lumpsumAmount) ?? 0
            let sip = Double(sipMonthly) ?? 0
            let current = Double(currentValue) ?? 0
            
            asset = Asset(
                name: assetName,
                amount: current,
                type: type,
                category: category,
                notes: notes,
                dateAdded: Date(),
                mutualFundDetails: MutualFundDetails(
                    lumpsum: lumpsum,
                    sipMonthly: sip,
                    sipStartDate: sipStartDate,
                    currentValue: current
                )
            )
            
        case .stocks:
            let shares = Int(numberOfShares) ?? 0
            let price = Double(pricePerShare) ?? 0
            let totalValue = Double(shares) * price
            
            asset = Asset(
                name: assetName,
                amount: totalValue,
                type: type,
                category: category,
                notes: notes,
                dateAdded: Date(),
                stockDetails: StockDetails(
                    companyName: companyName,
                    numberOfShares: shares,
                    pricePerShare: price,
                    purchaseDate: purchaseDate
                )
            )
            
        case .gold:
            let weight = Double(weightInGrams) ?? 0
            let price = Double(pricePerGram) ?? 0
            let totalValue = weight * price
            
            asset = Asset(
                name: assetName,
                amount: totalValue,
                type: type,
                category: category,
                notes: notes,
                dateAdded: Date(),
                goldDetails: GoldDetails(
                    weightInGrams: weight,
                    pricePerGram: price,
                    metalType: metalType
                )
            )
            
        case .fixedDeposit:
            let principal = Double(principalAmount) ?? 0
            
            asset = Asset(
                name: assetName,
                amount: principal,
                type: type,
                category: category,
                notes: notes,
                dateAdded: Date(),
                fixedDepositDetails: FixedDepositDetails(
                    bankName: bankName,
                    depositDate: depositDate,
                    maturityDate: maturityDate,
                    interestRate: Double(interestRate) ?? 0,
                    principalAmount: principal
                )
            )
            
        case .homeLoan, .carLoan, .educationLoan, .otherLoan:
            let total = Double(totalLoanAmount) ?? 0
            
            asset = Asset(
                name: assetName,
                amount: total,
                type: type,
                category: category,
                notes: notes,
                dateAdded: Date(),
                loanDetails: LoanDetails(
                    totalLoanAmount: total,
                    monthlyEMI: Double(monthlyEMI) ?? 0,
                    remainingAmount: total,
                    startDate: loanStartDate,
                    interestRate: Double(loanInterestRate) ?? 0,
                    tenure: Int(tenure) ?? 0
                )
            )
            
        case .healthInsurance, .lifeInsurance, .lic:
            let coverage = Double(coverageAmount) ?? 0
            
            asset = Asset(
                name: assetName,
                amount: coverage,
                type: type,
                category: category,
                notes: notes,
                dateAdded: Date(),
                insuranceDetails: InsuranceDetails(
                    monthlyPremium: Double(monthlyPremium) ?? 0,
                    coverageAmount: coverage,
                    startDate: insuranceStartDate,
                    policyNumber: policyNumber
                )
            )
        }
        
        viewModel.addAsset(asset)
        onSave()
    }
}
