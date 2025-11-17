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

    var body: some View {
        let s = spread.model

        VStack(spacing: 16) {
            Text(s.name).font(.title2).padding(.top)

            if drawn.isEmpty {
                Button(action: startDraw) {
                    Text(isShuffling ? "洗牌中..." : "开始抽牌")
                        .frame(maxWidth: .infinity).padding()
                        .background(AnyShapeStyle(.thinMaterial))
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.corner))
                }
                .disabled(isShuffling)
                
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        // 用 indices 避免类型推断超时，也避免 enumerated 的泛型炸裂
                        ForEach(drawn.indices, id: \.self) { idx in
                            let d = drawn[idx]
                            CardRowView(
                                index: idx + 1,
                                // 防止某些牌阵位名数组越界：安全取值
                                positionName: idx < s.positions.count ? s.positions[idx].name : "位置 \(idx+1)",
                                drawn: d
                            )
                        }

                        // 生成解读并保存（入历史）
                        PillButton(title: "生成解读",
                                   systemImage: "wand.and.stars",
                                   prominent: true) {
                            saveReading(alsoSave: true)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
        }
        .padding(.bottom)
        .navigationTitle("抽牌")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $latestReading) { r in
            ResultView(reading: r)
        }
    }

    // MARK: - Actions
    func startDraw() {
        isShuffling = true
        drawn.removeAll()

        let s = spread.model
        let count = spread.model.positions.count
        let picked = deck.draw(count: max(count, 1))
        
        print("count is \(count)")
        print("picked is \(picked)")

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
        latestReading = reading   // 触发 sheet(item:)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        showResult = true
    }
}

// MARK: - 单行牌面
private struct CardRowView: View {
    let index: Int
    let positionName: String
    let drawn: DrawnCard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(index). \(positionName)").font(.headline)
                Spacer()
                Text(drawn.isReversed ? "逆位" : "正位").foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            FlipCard {
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.corner)
                        .fill(AppTheme.gradient.opacity(0.12))
                        .overlay(RoundedRectangle(cornerRadius: AppTheme.corner).stroke(.quaternary, lineWidth: 1))
                    Text("轻点翻牌").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(AppTheme.tarotAspect, contentMode: .fit)
                .padding(.horizontal)
            } back: {
                TarotCardFace(
                    assetName: drawn.card.image.assetName,
                    title: drawn.card.name.zh,
                    isReversed: drawn.isReversed
                )
                .padding(.horizontal)
            }
        }
    }
}
