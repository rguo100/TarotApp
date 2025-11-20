import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasOnboarded") var hasOnboarded = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            VStack(spacing: 8) {
                Text("塔罗").font(.largeTitle).bold()
                Text("每日一抽 · 三张牌 · 凯尔特十字\n支持正/逆位与历史记录")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("仅作娱乐与自我反思", systemImage: "sparkles")
                Label("不收集个人隐私（本地存储）", systemImage: "lock")
                Label("可后续启用 AI 文案（可关闭）", systemImage: "wand.and.stars")
            }.padding(.horizontal)
            
            PillButton(title: "同意并开始", systemImage: "hand.thumbsup.fill", prominent: true) {
                hasOnboarded = true
            }
            .padding(.horizontal)
            Spacer()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemBackground),
                    Color(UIColor.systemBackground).opacity(0.6)
                ]),
                startPoint: .top, endPoint: .bottom
            )
        )
        .ignoresSafeArea()
    }
}

