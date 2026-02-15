import SwiftUI

struct LoanDetailView: View {
    let asset: Asset
    @ObservedObject var viewModel: BudgetViewModel
    @State private var showingPaymentSheet = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let details = asset.loanDetails {
                    // Loan Overview Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Remaining Amount")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("₹\(formatAmount(details.remainingAmount))")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.red)
                            }
                            
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: asset.type.icon)
                                    .font(.system(size: 28, weight: .medium))
                                    .foregroundStyle(Color.red)
                            }
                        }
                        
                        Divider()
                        
                        VStack(spacing: 12) {
                            InfoRow(label: "Total Loan", value: "₹\(formatAmount(details.totalLoanAmount))")
                            InfoRow(label: "Monthly EMI", value: "₹\(formatAmount(details.monthlyEMI))")
                            InfoRow(label: "Interest Rate", value: "\(String(format: "%.2f", details.interestRate))%")
                            InfoRow(label: "Tenure", value: "\(details.tenure) months")
                            InfoRow(label: "Payments Made", value: "\(details.emiPayments.count)")
                            
                            // Progress bar
                            let progress = 1 - (details.remainingAmount / details.totalLoanAmount)
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Paid Off")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(Int(progress * 100))%")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                                ProgressView(value: progress)
                                    .tint(.green)
                                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(20)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.06), radius: 8, x: 0, y: 3)
                    
                    // Payment History Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Payment History")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            if !details.emiPayments.isEmpty {
                                Text("\(details.emiPayments.count) payments")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        
                        if details.emiPayments.isEmpty {
                            // Empty State
                            VStack(spacing: 12) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 50))
                                    .foregroundColor(.secondary)
                                
                                Text("No payments yet")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Record your first EMI payment")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(20)
                            .padding(.horizontal)
                        } else {
                            // Payment List
                            VStack(spacing: 12) {
                                ForEach(details.emiPayments.sorted(by: { $0.paymentDate > $1.paymentDate })) { payment in
                                    PaymentCard(payment: payment)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(asset.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingPaymentSheet = true
                } label: {
                    Label("Pay EMI", systemImage: "plus.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                }
            }
        }
        .sheet(isPresented: $showingPaymentSheet) {
            RecordEMIPaymentView(asset: asset, viewModel: viewModel)
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
    }
}

struct InfoRow: View {
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
    }
}

struct PaymentCard: View {
    let payment: EMIPayment
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("₹\(formatAmount(payment.amount))")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(formatDate(payment.paymentDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !payment.notes.isEmpty {
                    Text(payment.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.04), radius: 4, x: 0, y: 2)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct RecordEMIPaymentView: View {
    let asset: Asset
    @ObservedObject var viewModel: BudgetViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var amount: String = ""
    @State private var paymentDate = Date()
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Loan")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(asset.name)
                            .fontWeight(.semibold)
                    }
                    
                    if let details = asset.loanDetails {
                        HStack {
                            Text("Monthly EMI")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("₹\(formatAmount(details.monthlyEMI))")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("Remaining")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("₹\(formatAmount(details.remainingAmount))")
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                    }
                } header: {
                    Text("Loan Details")
                }
                
                Section {
                    HStack {
                        Text("₹")
                            .foregroundColor(.secondary)
                        TextField("Enter amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    DatePicker("Payment Date", selection: $paymentDate, displayedComponents: .date)
                    
                    TextField("Notes (optional)", text: $notes)
                } header: {
                    Text("Payment Information")
                }
                
                if let details = asset.loanDetails, let amountValue = Double(amount), amountValue > 0 {
                    Section {
                        HStack {
                            Text("New Remaining")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("₹\(formatAmount(max(0, details.remainingAmount - amountValue)))")
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    } header: {
                        Text("After Payment")
                    }
                }
            }
            .navigationTitle("Record EMI Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePayment()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var isValid: Bool {
        guard let amountValue = Double(amount), amountValue > 0 else { return false }
        return true
    }
    
    private func savePayment() {
        guard let amountValue = Double(amount) else { return }
        
        viewModel.recordEMIPayment(for: asset, amount: amountValue, date: paymentDate, notes: notes)
        dismiss()
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
    }
}
