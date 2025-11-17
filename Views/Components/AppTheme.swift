import SwiftUI

struct AppTheme {
    static let corner: CGFloat = 16
    static let cardHeight: CGFloat = 180
    
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
            .background(prominent ? AppTheme.gradient : .thinMaterial)
            .foregroundStyle(prominent ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.corner))
        }
    }
}

