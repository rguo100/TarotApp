import SwiftUI
import UIKit

struct DrawView: View {
    @EnvironmentObject var deck: TarotDeck
//    @EnvironmentObject var history: ReadingHistoryStore

    let question: String
    let spread: SpreadPreset
    let intentHint: IntentUI?

    @State private var drawn: [DrawnCard] = []
    @State private var isShuffling = false

    @State private var showResult = false
    @State private var latestReading: Reading?
    
    private var spreadModel: Spread {
            spread.model
        }
    

    var body: some View {
        VStack(spacing: 16) {
            if drawn.isEmpty {
                emptyStateView
            }
            else {
                cardsListView
            }
        }
        .padding(.bottom)
        .navigationTitle("抽牌")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $latestReading) { r in
            ResultView(reading: r)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("tarot_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
    private var emptyStateView: some View {
        VStack {
            Text("集中精神，默念你心中的问题 \n点击开始抽牌...")
                .multilineTextAlignment(.center)
                .fontWeight(.medium)
                .font(.title2)
                .padding(.top, 150)
                .foregroundColor(MysticTheme.light)
            Button(action: startDraw) {
                Text(isShuffling ? "洗牌中..." : "开始抽牌")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(LinearGradient(colors: [MysticTheme.light,MysticTheme.white],startPoint: .top, endPoint: .bottom))
                    .foregroundStyle(AnyShapeStyle(Color.black))
                    .clipShape(RoundedRectangle(cornerRadius: MysticTheme.corner))
            }
            .disabled(isShuffling)
            .frame(maxWidth: 280)
            .frame(maxWidth: .infinity)
            .padding(.top, 55)
            Spacer()
        }
    }
    
    private var cardsListView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(drawn.indices, id: \.self) { idx in
                    let d = drawn[idx]
                    let posName = idx < spreadModel.positions.count ? spreadModel.positions[idx].name : "位置 \(idx+1)"
                    CardRowView(
                        index: idx + 1,
                        positionName: posName,
                        drawn: d,
                        intent: intentHint
                    )
                }
                Spacer()
                PillButton(title: "生成深度解读",systemImage: "wand.and.stars",prominent: true) {
                    saveReading(alsoSave: true)
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Actions
    func startDraw() {
        isShuffling = true
        drawn.removeAll()

        let s = spread.model
        let count = spread.model.positions.count
        let picked = deck.draw(count: max(count, 1))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.drawn = picked.enumerated().map { (idx, c) in
                DrawnCard(
                    card: c,
                    isReversed: deck.isReversed(),
                    positionIndex: idx
                )
            }
            isShuffling = false
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            print("抽到 \(drawn.count) 张牌 for spread=\(s.id)")
        }
    }

    func saveReading(alsoSave: Bool) {
        var reading = Reading(
            timestamp: Date(),
            question: question,
            spreadId: spread.model.id,
            drawn: drawn
        )
        reading.intentHint = intentHint?.rawValue
        reading.isPro = !question.trimmingCharacters(in: .whitespaces).isEmpty
//        if alsoSave { history.add(reading) }
        latestReading = reading
        UINotificationFeedbackGenerator().notificationOccurred(.success)
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
        return ["过去/原因", "现在/状态", "未来/趋势"][index] ?? "位置 \(index+1)"
    case "spread_celtic":
        let names = ["现状","挑战","潜意识","显意识","过去","未来","自我","环境","希望/恐惧","结果"]
        return names[index]
    default:
        return "位置 \(index+1)"
    }
}

// MARK: - 单行牌面
private struct CardRowView: View {
    let index: Int
    let positionName: String
    let drawn: DrawnCard
    let intent: IntentUI?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(index). \(positionName)").font(.headline).foregroundColor(MysticTheme.light)
                Spacer()
                Text(drawn.isReversed ? "逆位" : "正位").foregroundStyle(.secondary).foregroundColor(MysticTheme.white)
            }
            .padding(.horizontal)
            
            Text("轻点牌面查看能量解析")
                .font(.caption)
                .foregroundStyle(.primary)
                .foregroundColor(MysticTheme.white)
                .padding(.horizontal)
            
            FlipCard {
                TarotCardFace(
                    assetName: drawn.card.image.assetName,
                    title: drawn.card.name.zh,
                    isReversed: drawn.isReversed
                )
            } back: {
                CardEnergyBackView(drawn: drawn, intent: intent)
            }
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
    }
}

private struct CardEnergyBackView: View {
    let drawn: DrawnCard
    let intent: IntentUI?
    
    private var meanings: TarotCard.Meanings.MeaningDetail {
        drawn.isReversed ? drawn.card.meanings.reversed : drawn.card.meanings.upright
    }
    
    private var keywords: [String] {
        drawn.isReversed ? drawn.card.keywords.reversed : drawn.card.keywords.upright
    }
    
    private var focusLabel: String {
        CardEnergyBackView.focusLabel(intent: intent)
    }
    
    private var focusText: String {
        CardEnergyBackView.focusText(intent: intent, meanings: meanings)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: MysticTheme.corner)
                .fill(MysticTheme.light)
                .overlay(RoundedRectangle(cornerRadius: MysticTheme.corner)
                .stroke(MysticTheme.gold.opacity(0.5), lineWidth: 1))
            VStack(alignment: .leading) {
                Spacer()
                VStack(spacing: 12) {
                    Text(focusLabel)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(spacing: 8) {
                        Text("关键词：\(keywords.joined(separator: "、"))")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(focusText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("建议：\(meanings.advice)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .foregroundColor(MysticTheme.deep)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding()
        }
        .aspectRatio(MysticTheme.cardAspect, contentMode: .fit)
        .padding(.horizontal)
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }
    
    private static func focusLabel(intent: IntentUI?) -> String {
        guard let intent else { return "整体能量" }
        switch intent {
        case .love: return "爱情能量"
        case .money: return "财富能量"
        case .career: return "事业能量"
        case .general: return "整体能量"
        }
    }
        
    private static func focusText(intent: IntentUI?, meanings: TarotCard.Meanings.MeaningDetail) -> String {
        guard let intent else { return "总体：\(meanings.general)" }
        switch intent {
        case .love:
            let text = meanings.love.isEmpty ? meanings.general : meanings.love
            return "爱情：\(text)"
        case .money, .career:
            let text = meanings.career.isEmpty ? meanings.general : meanings.career
            return "事业/财富：\(text)"
        case .general:
            let text1 = meanings.love.isEmpty ? meanings.general : meanings.love
            let text2 = meanings.career.isEmpty ? meanings.general : meanings.career
            return "总体：\(meanings.general)\n情感：\(meanings.love)\n事业：\(meanings.career)"
        }
    }
}
