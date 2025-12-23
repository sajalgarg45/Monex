import SwiftUI

struct AddBudgetView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BudgetViewModel
    
    @State private var name = ""
    @State private var amount = ""
    @State private var icon = "cart.fill"
    @State private var color = "blue"
    
    private let icons = ["cart.fill", "fork.knife", "house.fill", "creditcard.fill", "airplane", "heart.fill", "book.fill", "dollarsign.circle.fill"]
    private let colors = ["blue", "red", "green", "orange", "purple", "yellow", "pink", "indigo"]
    
    private var isFormValid: Bool {
        !name.isEmpty && !amount.isEmpty && Double(amount) ?? 0 > 0
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Budget Details")) {
                    TextField("Budget Name", text: $name)
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Icon")) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(icons, id: \.self) { iconName in
                            IconButton(
                                iconName: iconName,
                                isSelected: icon == iconName,
                                onTap: {
                                    icon = iconName
                                },
                                color: color
                            )
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                Section(header: Text("Color")) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(colors, id: \.self) { colorName in
                            ColorButton(
                                colorName: colorName,
                                isSelected: color == colorName,
                                onTap: { color = colorName }
                            )
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationTitle("Add Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let amountValue = Double(amount) {
                            let newBudget = Budget(
                                name: name,
                                amount: amountValue,
                                icon: icon,
                                color: color
                            )
                            viewModel.addBudget(newBudget)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
}

struct IconButton: View {
    let iconName: String
    let isSelected: Bool
    let onTap: () -> Void
    let color: String
    
    private func getColor() -> Color {
        switch color {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "yellow": return .yellow
        default: return .blue
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            Image(systemName: iconName)
                .font(.title2)
                .frame(width: 50, height: 50)
                .background(isSelected ? getColor() : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle()) // Add this to prevent default button behavior
    }
}

struct ColorButton: View {
    let colorName: String
    let isSelected: Bool
    let onTap: () -> Void
    
    private func getColor() -> Color {
        switch colorName {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "yellow": return .yellow
        case "pink": return .pink
        case "indigo": return .indigo
        default: return .blue
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(getColor())
                    .frame(width: 50, height: 50)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddBudgetView(viewModel: BudgetViewModel())
}
