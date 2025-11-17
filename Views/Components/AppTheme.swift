import SwiftUI

struct AppTheme {
    static let corner: CGFloat = 16
    static let tarotAspect: CGFloat = 0.58
    
    static var gradient: LinearGradient {
        LinearGradient(
            colors: [Color.indigo, Color.purple],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title).font(.headline)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct PillButton: View {
    let title: String
    var systemImage: String? = nil
    var prominent = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let s = systemImage { Image(systemName: s) }
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                prominent ? AnyShapeStyle(AppTheme.gradient)
                          : AnyShapeStyle(.thinMaterial)
            )
            .foregroundStyle(prominent ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.corner))
        }
    }
}

