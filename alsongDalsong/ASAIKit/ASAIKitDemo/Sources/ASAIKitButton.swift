import SwiftUI

struct ASAIKitButton: View {
    var title: String
    var fontSize: CGFloat = 28
    var color: Color
    var isSelected: Bool = true
    var isDisabled: Bool = false
    
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("DoHyeon-Regular", size: fontSize))
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(lineWidth: 4)
                }
                .background(isDisabled ? Color(.systemGray4) : isSelected ? color : Color(.systemGray6))
                .cornerRadius(12)
        }
        .disabled(isDisabled)
        .buttonStyle(ASAIKitButtonStyle())
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .foregroundStyle(.black)
                .offset(x: 4, y: 4)
        }
    }
}

struct ASAIKitButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(
                x: configuration.isPressed ? 3 : 0,
                y: configuration.isPressed ? 3 : 0
            )
    }
}

#Preview {
    ASAIKitButton(title: "버튼", fontSize: 24, color: .orange) { }
        .padding()
}
