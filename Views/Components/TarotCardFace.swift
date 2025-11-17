import SwiftUI

struct TarotCardFace: View {
    let title: String
    let isReversed: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.corner)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.corner)
                        .strokeBorder(.quaternary)
                )
            Text(title)
                .font(.title3)
                .padding()
                .rotationEffect(.degrees(isReversed ? 180 : 0))
        }
        .frame(height: AppTheme.cardHeight)
        .rotation3DEffect(.degrees(isReversed ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(duration: 0.6), value: isReversed)
    }
}

