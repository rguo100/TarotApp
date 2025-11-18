////
////  UIAtoms.swift
////  TarotApp_Xcode
////
////  Created by Runnan Guo on 2025-11-17.
////
//import SwiftUI
//
//struct GlassCard<Content: View>: View {
//    var padding: CGFloat = 14
//    @ViewBuilder var content: () -> Content
//
//    var body: some View {
//        content()
//            .padding(padding)
//            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.corner, style: .continuous))
//            .overlay(
//                RoundedRectangle(cornerRadius: AppTheme.corner)
//                    .strokeBorder(.white.opacity(0.08))
//            )
//            .shadow(color: AppTheme.deep, radius: 16, x: 0, y: 8)
//    }
//}
//
//struct PrimaryButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.headline)
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 14)
//            .background(MysticTheme.accentGradient)
//            .foregroundStyle(.white)
//            .clipShape(RoundedRectangle(cornerRadius: AppTheme.corner, style: .continuous))
//            .scaleEffect(configuration.isPressed ? 0.98 : 1)
//            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 8)
//            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
//    }
//}
//
//struct SecondaryButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.headline)
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 14)
//            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.corner, style: .continuous))
//            .overlay(RoundedRectangle(cornerRadius: AppTheme.corner).stroke(.white.opacity(0.08)))
//            .foregroundStyle(.primary)
//            .scaleEffect(configuration.isPressed ? 0.98 : 1)
//            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
//    }
//}
