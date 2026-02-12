import SwiftUI

struct EditAssetView: View {
    let asset: Asset
    @ObservedObject var viewModel: BudgetViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var assetName: String
    @State private var notes: String
    
    // Mutual Fund fields
    @State private var lumpsumAmount: String
    @State private var sipMonthly: String
    @State private var sipStartDate: Date
    @State private var currentValue: String
    
    // Stock fields
    @State private var companyName: String
    @State private var numberOfShares: String
    @State private var pricePerShare: String
    @State private var purchaseDate: Date
    
    // Gold fields
    @State private var metalType: String
    @State private var weightInGrams: String
    @State private var pricePerGram: String
    
    // FD fields
    @State private var bankName: String
    @State private var principalAmount: String
    @State private var interestRate: String
    @State private var depositDate: Date
    @State private var maturityDate: Date
    
    // Loan fields
    @State private var totalLoanAmount: String
    @State private var monthlyEMI: String
    @State private var remainingAmount: String
    @State private var loanInterestRate: String
    @State private var tenure: String
    @State private var loanStartDate: Date
    
    // Insurance fields
    @State private var monthlyPremium: String
    @State private var coverageAmount: String
    @State private var policyNumber: String
    @State private var insuranceStartDate: Date
    
    init(asset: Asset, viewModel: BudgetViewModel) {
        self.asset = asset
        self.viewModel = viewModel
        
        _assetName = State(initialValue: asset.name)
        _notes = State(initialValue: asset.notes)
        
        // Initialize based on type
        if let mf = asset.mutualFundDetails {
            _lumpsumAmount = State(initialValue: "\(Int(mf.lumpsum))")
            _sipMonthly = State(initialValue: "\(Int(mf.sipMonthly))")
            _sipStartDate = State(initialValue: mf.sipStartDate ?? Date())
            _currentValue = State(initialValue: "\(Int(mf.currentValue))")
        } else {
            _lumpsumAmount = State(initialValue: "")
            _sipMonthly = State(initialValue: "")
            _sipStartDate = State(initialValue: Date())
            _currentValue = State(initialValue: "")
        }
        
        if let stock = asset.stockDetails {
            _companyName = State(initialValue: stock.companyName)
            _numberOfShares = State(initialValue: "\(stock.numberOfShares)")
            _pricePerShare = State(initialValue: "\(Int(stock.pricePerShare))")
            _purchaseDate = State(initialValue: stock.purchaseDate)
        } else {
            _companyName = State(initialValue: "")
            _numberOfShares = State(initialValue: "")
            _pricePerShare = State(initialValue: "")
            _purchaseDate = State(initialValue: Date())
        }
        
        if let gold = asset.goldDetails {
            _metalType = State(initialValue: gold.metalType)
            _weightInGrams = State(initialValue: "\(Int(gold.weightInGrams))")
            _pricePerGram = State(initialValue: "\(Int(gold.pricePerGram))")
        } else {
            _metalType = State(initialValue: "Gold")
            _weightInGrams = State(initialValue: "")
            _pricePerGram = State(initialValue: "")
        }
        
        if let fd = asset.fixedDepositDetails {
            _bankName = State(initialValue: fd.bankName)
            _principalAmount = State(initialValue: "\(Int(fd.principalAmount))")
            _interestRate = State(initialValue: "\(fd.interestRate)")
            _depositDate = State(initialValue: fd.depositDate)
            _maturityDate = State(initialValue: fd.maturityDate)
        } else {
            _bankName = State(initialValue: "")
            _principalAmount = State(initialValue: "")
            _interestRate = State(initialValue: "")
            _depositDate = State(initialValue: Date())
            _maturityDate = State(initialValue: Date())
        }
        
        if let loan = asset.loanDetails {
            _totalLoanAmount = State(initialValue: "\(Int(loan.totalLoanAmount))")
            _monthlyEMI = State(initialValue: "\(Int(loan.monthlyEMI))")
            _remainingAmount = State(initialValue: "\(Int(loan.remainingAmount))")
            _loanInterestRate = State(initialValue: "\(loan.interestRate)")
            _tenure = State(initialValue: "\(loan.tenure)")
            _loanStartDate = State(initialValue: loan.startDate)
        } else {
            _totalLoanAmount = State(initialValue: "")
            _monthlyEMI = State(initialValue: "")
            _remainingAmount = State(initialValue: "")
            _loanInterestRate = State(initialValue: "")
            _tenure = State(initialValue: "")
            _loanStartDate = State(initialValue: Date())
        }
        
        if let insurance = asset.insuranceDetails {
            _monthlyPremium = State(initialValue: "\(Int(insurance.monthlyPremium))")
            _coverageAmount = State(initialValue: "\(Int(insurance.coverageAmount))")
            _policyNumber = State(initialValue: insurance.policyNumber)
            _insuranceStartDate = State(initialValue: insurance.startDate)
        } else {
            _monthlyPremium = State(initialValue: "")
            _coverageAmount = State(initialValue: "")
            _policyNumber = State(initialValue: "")
            _insuranceStartDate = State(initialValue: Date())
        }
    }
    
    var body: some View {
        NavigationView {
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
            .navigationTitle("Edit \(asset.type.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAsset()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    @ViewBuilder
    private var formContent: some View {
        switch asset.type {
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
            
            TextField("Remaining Amount (₹)", text: $remainingAmount)
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
    
    private func saveAsset() {
        var updatedAsset = asset
        updatedAsset.name = assetName
        updatedAsset.notes = notes
        
        switch asset.type {
        case .mutualFunds:
            let current = Double(currentValue) ?? asset.amount
            updatedAsset.amount = current
            updatedAsset.mutualFundDetails = MutualFundDetails(
                lumpsum: Double(lumpsumAmount) ?? 0,
                sipMonthly: Double(sipMonthly) ?? 0,
                sipStartDate: sipStartDate,
                currentValue: current
            )
            
        case .stocks:
            let shares = Int(numberOfShares) ?? 0
            let price = Double(pricePerShare) ?? 0
            updatedAsset.amount = Double(shares) * price
            updatedAsset.stockDetails = StockDetails(
                companyName: companyName,
                numberOfShares: shares,
                pricePerShare: price,
                purchaseDate: purchaseDate
            )
            
        case .gold:
            let weight = Double(weightInGrams) ?? 0
            let price = Double(pricePerGram) ?? 0
            updatedAsset.amount = weight * price
            updatedAsset.goldDetails = GoldDetails(
                weightInGrams: weight,
                pricePerGram: price,
                metalType: metalType
            )
            
        case .fixedDeposit:
            let principal = Double(principalAmount) ?? asset.amount
            updatedAsset.amount = principal
            updatedAsset.fixedDepositDetails = FixedDepositDetails(
                bankName: bankName,
                depositDate: depositDate,
                maturityDate: maturityDate,
                interestRate: Double(interestRate) ?? 0,
                principalAmount: principal
            )
            
        case .homeLoan, .carLoan, .educationLoan, .otherLoan:
            let remaining = Double(remainingAmount) ?? asset.amount
            updatedAsset.amount = remaining
            updatedAsset.loanDetails = LoanDetails(
                totalLoanAmount: Double(totalLoanAmount) ?? 0,
                monthlyEMI: Double(monthlyEMI) ?? 0,
                remainingAmount: remaining,
                startDate: loanStartDate,
                interestRate: Double(loanInterestRate) ?? 0,
                tenure: Int(tenure) ?? 0
            )
            
        case .healthInsurance, .lifeInsurance, .lic:
            let coverage = Double(coverageAmount) ?? asset.amount
            updatedAsset.amount = coverage
            updatedAsset.insuranceDetails = InsuranceDetails(
                monthlyPremium: Double(monthlyPremium) ?? 0,
                coverageAmount: coverage,
                startDate: insuranceStartDate,
                policyNumber: policyNumber
            )
        }
        
        viewModel.updateAsset(updatedAsset)
        presentationMode.wrappedValue.dismiss()
    }
}
