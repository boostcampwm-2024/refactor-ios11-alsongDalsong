import SwiftUI

struct ASAIKitMessage: View {
    @Binding var isPresented: Bool
    @Binding var message: String
    
    var body: some View {
        VStack {
            Text(message)
                .font(.custom("DoHyeon-Regular", size: 20))
                .padding(.bottom)
            
            if message.contains("업로드 중...") {
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.extraLarge)
            } else {
                ASAIKitButton(title: "확인", fontSize: 22, color: .green) {
                    isPresented = false
                    message = ""
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(lineWidth: 4)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    @Previewable @State var isPresented = true
    @Previewable @State var message = "오류 메세지"
    
    ASAIKitMessage(isPresented: $isPresented, message: $message)
}

#Preview {
    @Previewable @State var isPresented = true
    @Previewable @State var message = "업로드 중..."
    
    ASAIKitMessage(isPresented: $isPresented, message: $message)
}
