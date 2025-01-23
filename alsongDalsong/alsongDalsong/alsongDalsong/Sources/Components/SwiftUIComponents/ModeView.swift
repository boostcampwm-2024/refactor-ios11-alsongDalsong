import SwiftUI
import ASEntity

struct ModeView: View {
    let modeInfo: Mode
    let width: CGFloat
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.asSystem)
                .cornerRadius(12)
                .shadow(color: .asShadow, radius: 0, x: 5, y: 5)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 3))
            VStack {
                Text(LocalizedStringResource(stringLiteral: modeInfo.title))
                    .font(.doHyeon(size: 32))
                    .padding(.top, 16)
                    .layoutPriority(1)
                GeometryReader { geometry in
                    VStack {
                        Image(modeInfo.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.horizontal)
                            .frame(width: width, height: min(geometry.size.height * 0.6, 150))
                        
                        Text(LocalizedStringResource(stringLiteral: modeInfo.description))
                            .font(.doHyeon(size: 20))
                            .minimumScaleFactor(0.01)
                            .lineLimit(nil)
                            .padding(.top, 0)
                            .padding(.horizontal)
                            .frame(maxHeight: geometry.size.height * 0.3, alignment: .top)
                    }
                }
            }
            
        }
        .frame(width: width)
    }
}
