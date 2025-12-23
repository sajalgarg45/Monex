import SwiftUI
import Combine

// Extension to create chat bubble shapes
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    // Standard iOS card style
    func cardStyle() -> some View {
        self.modifier(CardStyle())
    }
    
    // Standard iOS button style
    func primaryButton(color: Color = .blue) -> some View {
        self.modifier(PrimaryButton(color: color))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Standard iOS card style
struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 8, x: 0, y: 2)
    }
}

// Standard iOS primary button
struct PrimaryButton: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
    }
} 