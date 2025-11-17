import SwiftUI

struct TarotCardFace: View {
    let assetName: String?
    let title: String
    let isReversed: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.corner)
                .fill(AppTheme.gradient.opacity(0.10))
                .overlay(RoundedRectangle(cornerRadius: AppTheme.corner)
                    .stroke(.quaternary, lineWidth: 1))

            if let name = assetName, UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .interpolation(.high)     // 提高清晰度
                    .antialiased(true)
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.corner - 4))
                    .shadow(radius: 2, y: 1)
                    .padding(8)
            } else {
                Text(title)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .padding()
            }
        }
        // 关键两行：占满宽度 + 按塔罗比例自适应高度
        .frame(maxWidth: .infinity)
        .aspectRatio(AppTheme.tarotAspect, contentMode: .fit)
        .rotationEffect(.degrees(isReversed ? 180 : 0))
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isReversed)
    }
}

