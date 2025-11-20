import SwiftUI

struct TarotCardFace: View {
    let assetName: String
    let title: String
    let isReversed: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.thinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18).stroke(MysticTheme.gold.opacity(0.7), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 18, x: 0, y: 10)

                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .padding(12)
                    .rotationEffect(isReversed ? .degrees(180) : .degrees(0))
                    .animation(.easeInOut(duration: 0.35), value: isReversed)
            }
            .aspectRatio(MysticTheme.cardAspect, contentMode: .fit)

            HStack(spacing: 8) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                if isReversed {
                    Text("逆位").font(.caption2).padding(.horizontal, 6).padding(.vertical, 2)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                Spacer()
            }
            .foregroundStyle(.white.opacity(0.95))
        }
        .padding(.horizontal, 6)
    }
}
