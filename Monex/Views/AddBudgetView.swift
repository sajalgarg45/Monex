import SwiftUI

struct AddBudgetView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BudgetViewModel
    
    @State private var name = ""
    @State private var amount = ""
    @State private var icon = "banknote.fill"
    @State private var color = "blue"
    @State private var emoji = ""
    
    private let icons = ["banknote.fill", "cart.fill", "house.fill", "car.fill", "creditcard.fill", "gift.fill", "book.fill", "medical.thermometer.fill", "wifi", "bus.fill", "airplane", "tram.fill"]
    private let colors = ["blue", "red", "green", "orange", "purple", "yellow"]
    
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
                    VStack(spacing: 10) {
                        // Preview of selected icon or emoji
                        if !emoji.isEmpty {
                            Text(emoji)
                                .font(.system(size: 40))
                                .frame(width: 60, height: 60)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(12)
                        } else {
                            Image(systemName: icon)
                                .font(.system(size: 40))
                                .frame(width: 60, height: 60)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(12)
                        }
                        // Emoji input
                        TextField("Or enter emoji (e.g. 🛒)", text: $emoji)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .frame(width: 80)
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                            .onChange(of: emoji) { _ in
                                // When emoji is entered, we don't need to clear icon
                                // The logic will handle this in the preview and save
                            }
                        Text("Choose an SF Symbol below or enter an emoji above")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 8)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                        ForEach(icons, id: \.self) { iconName in
                            IconButton(
                                iconName: iconName,
                                isSelected: icon == iconName && emoji.isEmpty,
                                onTap: {
                                    icon = iconName
                                    emoji = "" // Clear emoji when icon is selected
                                },
                                color: color
                            )
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                Section(header: Text("Color")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
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
                            let chosenIcon = !emoji.isEmpty ? emoji : icon
                            let newBudget = Budget(
                                name: name,
                                amount: amountValue,
                                icon: chosenIcon,
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
        default: return .blue
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            Circle()
                .fill(getColor())
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .strokeBorder(isSelected ? .white : Color.clear, lineWidth: 3)
                        .padding(4)
                        .background(
                            Circle()
                                .fill(isSelected ? getColor().opacity(0.3) : Color.clear)
                                .padding(2)
                        )
                )
                .shadow(color: isSelected ? getColor() : Color.clear, radius: 5)
        }
        .buttonStyle(PlainButtonStyle()) // Add this to prevent default button behavior
    }
}

#Preview {
    AddBudgetView(viewModel: BudgetViewModel())
}
