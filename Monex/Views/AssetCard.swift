import SwiftUI

struct AssetCard: View {
    let asset: Asset
    @ObservedObject var viewModel: BudgetViewModel
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(assetColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: asset.type.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(assetColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(asset.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(asset.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Details based on asset type
            assetDetails
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.06), radius: 8, x: 0, y: 3)
        .sheet(isPresented: $showingEditSheet) {
            EditAssetView(asset: asset, viewModel: viewModel)
        }
        .alert("Delete Asset", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteAsset(asset)
            }
        } message: {
            Text("Are you sure you want to delete \(asset.name)?")
        }
    }
    
    @ViewBuilder
    private var assetDetails: some View {
        switch asset.category {
        case .investments:
            investmentDetails
        case .loans:
            loanDetails
        case .insurance:
            insuranceDetails
        }
    }
    
    @ViewBuilder
    private var investmentDetails: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Total Amount
            HStack {
                Text("Current Value")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("₹\(formatAmount(asset.amount))")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            
            // Type-specific details
            if let mfDetails = asset.mutualFundDetails {
                mutualFundDetailsView(mfDetails)
            } else if let stockDetails = asset.stockDetails {
                stockDetailsView(stockDetails)
            } else if let goldDetails = asset.goldDetails {
                goldDetailsView(goldDetails)
            } else if let fdDetails = asset.fixedDepositDetails {
                fixedDepositDetailsView(fdDetails)
            }
        }
    }
    
    private func mutualFundDetailsView(_ details: MutualFundDetails) -> some View {
        VStack(spacing: 8) {
            DetailRow(label: "Lumpsum Investment", value: "₹\(formatAmount(details.lumpsum))")
            DetailRow(label: "Monthly SIP", value: "₹\(formatAmount(details.sipMonthly))")
            if let startDate = details.sipStartDate {
                DetailRow(label: "SIP Start Date", value: formatDate(startDate))
            }
        }
    }
    
    private func stockDetailsView(_ details: StockDetails) -> some View {
        VStack(spacing: 8) {
            DetailRow(label: "Company", value: details.companyName)
            DetailRow(label: "Shares", value: "\(details.numberOfShares)")
            DetailRow(label: "Price/Share", value: "₹\(formatAmount(details.pricePerShare))")
            DetailRow(label: "Purchase Date", value: formatDate(details.purchaseDate))
        }
    }
    
    private func goldDetailsView(_ details: GoldDetails) -> some View {
        VStack(spacing: 8) {
            DetailRow(label: "Type", value: details.metalType)
            DetailRow(label: "Weight", value: "\(Int(details.weightInGrams))g")
            DetailRow(label: "Price/Gram", value: "₹\(formatAmount(details.pricePerGram))")
        }
    }
    
    private func fixedDepositDetailsView(_ details: FixedDepositDetails) -> some View {
        VStack(spacing: 8) {
            DetailRow(label: "Bank", value: details.bankName)
            DetailRow(label: "Principal", value: "₹\(formatAmount(details.principalAmount))")
            DetailRow(label: "Interest Rate", value: "\(String(format: "%.2f", details.interestRate))%")
            DetailRow(label: "Deposit Date", value: formatDate(details.depositDate))
            DetailRow(label: "Maturity Date", value: formatDate(details.maturityDate))
        }
    }
    
    @ViewBuilder
    private var loanDetails: some View {
        if let details = asset.loanDetails {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Remaining Amount")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("₹\(formatAmount(details.remainingAmount))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.red)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                
                VStack(spacing: 8) {
                    DetailRow(label: "Total Loan", value: "₹\(formatAmount(details.totalLoanAmount))")
                    DetailRow(label: "Monthly EMI", value: "₹\(formatAmount(details.monthlyEMI))")
                    DetailRow(label: "Interest Rate", value: "\(String(format: "%.2f", details.interestRate))%")
                    DetailRow(label: "Tenure", value: "\(details.tenure) months")
                    
                    // Progress bar
                    let progress = 1 - (details.remainingAmount / details.totalLoanAmount)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Paid Off")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(progress * 100))%")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        ProgressView(value: progress)
                            .tint(.green)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var insuranceDetails: some View {
        if let details = asset.insuranceDetails {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Coverage")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("₹\(formatAmount(details.coverageAmount))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                
                VStack(spacing: 8) {
                    DetailRow(label: "Monthly Premium", value: "₹\(formatAmount(details.monthlyPremium))")
                    DetailRow(label: "Policy Number", value: details.policyNumber)
                    DetailRow(label: "Start Date", value: formatDate(details.startDate))
                }
            }
        }
    }
    
    private var assetColor: Color {
        switch asset.type.color {
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "purple": return .purple
        case "orange": return .orange
        case "red": return .red
        case "cyan": return .cyan
        case "indigo": return .indigo
        case "pink": return .pink
        case "teal": return .teal
        default: return .gray
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        Int(amount).formatted()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 2)
    }
}
