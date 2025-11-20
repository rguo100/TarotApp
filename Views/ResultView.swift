import SwiftUI
import UIKit

struct ResultView: View {
    let reading: Reading
    
    @State private var polished: [PolishedChunk] = []
    // 分享功能相关
    @State private var shareImage: UIImage? = nil
    @State private var showShare = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(reading.timestamp, style: .date).foregroundStyle(.secondary)
                
                // 深度解读（润色）
                if !polished.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("✨ 深度解读")
                            .font(.title3).bold()
                        ForEach(polished) { p in
                            Text(p.text)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                if !reading.question.isEmpty {
                    Text(reading.question)
                        .font(.title2).bold()
                }
                
                Text("⚠️ 免责声明：本结果仅供娱乐与自我反思，不构成医疗、法律或财务建议。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("解读结果")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if polished.isEmpty {
                let spread = LocalTarotInterpreter.resolveSpread(by: reading.spreadId)
                let explicit = LocalTarotInterpreter.intent(from: reading.intentHint.flatMap(IntentUI.init(rawValue:)))
                polished = LocalTarotInterpreter.shared.generate(
                    question: reading.question,
                    spread: spread,
                    drawn: reading.drawn,
                    explicitIntent: explicit
                )
            }
        }
        // 🔗 分享按钮放在右上角
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let img = ShareRenderer.makeImage(from: ResultShareCard(reading: reading))
                    shareImage = img
                    showShare = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShare) {
            if let img = shareImage {
                ShareSheet(activityItems: [img])
            } else {
                Text("生成中…")
            }
        }
    }
    
    func summary(for d: DrawnCard) -> String {
        let m = d.isReversed ? d.card.meanings.reversed : d.card.meanings.upright
        return "关键词：\((d.isReversed ? d.card.keywords.reversed : d.card.keywords.upright).joined(separator: "、"))\n" +
        "总体：\(m.general)\n情感：\(m.love)\n事业：\(m.career)\n建议：\(m.advice)"
    }
    
    func positionName(index: Int, spreadId: String) -> String {
        switch spreadId {
        case "spread_one":
            return "此刻能量"
        case "spread_three":
            return ["过去/原因", "现在/状态", "未来/趋势"][safe: index] ?? "位置 \(index+1)"
        case "spread_celtic":
            let names = ["现状","挑战","潜意识","显意识","过去","未来","自我","环境","希望/恐惧","结果"]
            return names[safe: index] ?? "位置 \(index+1)"
        default:
            return "位置 \(index+1)"
        }
    }
}

private extension Array {
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - 分享功能相关组件
//
struct ShareRenderer {
    @MainActor
    static func makeImage(from view: some View) -> UIImage {
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage ?? UIImage()
    }
}

struct ResultShareCard: View {
    let reading: Reading
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("塔罗解读").font(.title2).bold()
            Text(reading.question.isEmpty ? "未命名问题" : reading.question)
            ForEach(Array(reading.drawn.enumerated()), id: \.offset) { idx, d in
                let m = d.isReversed ? d.card.meanings.reversed : d.card.meanings.upright
                VStack(alignment: .leading) {
                    Text("\(idx+1). \(d.card.name.zh) \(d.isReversed ? "(逆位)" : "")").bold()
                    Text("关键词：\((d.isReversed ? d.card.keywords.reversed : d.card.keywords.upright).joined(separator: "、"))")
                        .font(.footnote)
                    Text("总体：\(m.general)").font(.footnote)
                }
            }
            Text("仅供娱乐与自我反思").font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(width: 320)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

