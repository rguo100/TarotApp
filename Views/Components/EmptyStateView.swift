import SwiftUI

struct EmptyStateView: View {
    var title: String
    var actionTitle: String
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 48, weight: .semibold))
                .padding(12)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .accessibilityHidden(true)
            
            Text(title)
                .font(.title3).bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            PillButton(title: actionTitle, systemImage: "wand.and.stars", prominent: true, action: action)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
}

