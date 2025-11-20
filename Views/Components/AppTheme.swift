import SwiftUI

enum MysticTheme {
    static let gold = Color(hex: 0xD4AF37)
    static let goldSoft = Color(hex: 0xE6D08B)
    static let deep = Color(hex: 0x0A0A12)
    static let ink  = Color(hex: 0x1A1A26)
    static let white = Color(hex: 0xFFFFFF)
    static let light = Color(hex: 0xE4E1E1)
    static let nebulaTop = Color(hex: 0x0A0A12)
    static let nebulaBottom = Color(hex: 0x1C1B29)
    static let corner: CGFloat = 16
    static let cardAspect: CGFloat = 0.58
}

// 背景：深色渐变/星点
struct MysticBackground: View {
    var body: some View {
        LinearGradient(colors: [MysticTheme.nebulaTop, MysticTheme.nebulaBottom],
                       startPoint: .top, endPoint: .bottom)
            .overlay(
                RadialGradient(colors: [.clear, Color.white.opacity(0.04), .clear],
                               center: .topTrailing, startRadius: 60, endRadius: 280)
            )
    }
}

// 金色标题
struct GoldTitle: View {
    let text: String
    init(_ t: String) { self.text = t }
    var body: some View {
        Text(text)
            .font(.largeTitle.bold())
            .foregroundStyle(
                LinearGradient(colors: [MysticTheme.gold, MysticTheme.goldSoft],
                               startPoint: .top, endPoint: .bottom)
            )
    }
}

// 玻璃卡片
struct GlassCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        RoundedRectangle(cornerRadius: MysticTheme.corner, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: MysticTheme.corner)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .overlay(
                content
            )
    }
}

// 神秘按钮
enum MysticButtonStyleKind { case filledGold, filledDark,filledLight, glassOutline }

struct MysticButton: View {
    let title: String
    let style: MysticButtonStyleKind
    var systemImage: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        if let action {
            Button(action: action) {
                HStack(spacing: 8) {
                    if let s = systemImage { Image(systemName: s) }
                    Text(title)
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(background)
                .foregroundStyle(foreground)
                .overlay(
                    RoundedRectangle(cornerRadius: MysticTheme.corner)
                        .strokeBorder(border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: MysticTheme.corner, style: .continuous))
                .shadow(color: Color.black.opacity(0.25), radius: 8, y: 6)
            }
        }
        else {
            HStack(spacing: 8) {
                if let s = systemImage { Image(systemName: s) }
                Text(title)
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(background)
            .foregroundStyle(foreground)
            .overlay(
                RoundedRectangle(cornerRadius: MysticTheme.corner)
                    .strokeBorder(border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: MysticTheme.corner, style: .continuous))
            .shadow(color: Color.black.opacity(0.25), radius: 8, y: 6)
        }
    }
    
    private var background: AnyShapeStyle {
        switch style {
        case .filledGold:
            return AnyShapeStyle(
                LinearGradient(colors: [MysticTheme.gold, MysticTheme.goldSoft],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        case .filledDark:
            return AnyShapeStyle(
                LinearGradient(colors: [MysticTheme.ink, MysticTheme.deep],
                               startPoint: .top, endPoint: .bottom)
            )
        case .filledLight:
            return AnyShapeStyle(
                LinearGradient(colors: [MysticTheme.light, MysticTheme.white],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        case .glassOutline:
            return AnyShapeStyle(.ultraThinMaterial)
        }
    }
    
    private var foreground: AnyShapeStyle {
        switch style {
        case .filledGold:
            return AnyShapeStyle(Color.black.opacity(0.85))
        case .filledLight:
            return AnyShapeStyle(Color.black.opacity(0.85))
        default:
            return AnyShapeStyle(Color.white)
        }
    }
    
    private var border: Color {
        switch style {
        case .glassOutline: return .white.opacity(0.15)
        default:            return .clear
        }
    }
}

struct AppTheme {
    static var gradient: LinearGradient {
        LinearGradient(
            colors: [Color.indigo, Color.purple],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
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
            .clipShape(RoundedRectangle(cornerRadius: MysticTheme.corner))
        }
    }
}


// 十六进制颜色
extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255.0,
                  green: Double((hex >> 8) & 0xFF) / 255.0,
                  blue: Double(hex & 0xFF) / 255.0,
                  opacity: alpha)
    }
}
