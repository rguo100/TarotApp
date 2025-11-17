import SwiftUI

struct DrawView: View {
    @EnvironmentObject var deck: TarotDeck
    @EnvironmentObject var history: ReadingHistoryStore
    
    let question: String
    let spread: SpreadPreset
    @State private var drawn: [DrawnCard] = []
    @State private var isShuffling = false
    
    var body: some View {
        let s = spread.model
        VStack(spacing: 16) {
            Text(s.name).font(.title2).padding(.top)
            if drawn.isEmpty {
                Button(action: startDraw) {
                    Text(isShuffling ? "洗牌中..." : "开始抽牌")
                        .frame(maxWidth: .infinity).padding()
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }.disabled(isShuffling)
                Text("问题：\(question.isEmpty ? "（未填写）" : question)").foregroundStyle(.secondary)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(drawn.enumerated()), id: \.offset) { idx, d in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("\(idx+1). \(s.positions[idx].name)").font(.headline)
                                    Spacer()
                                    Text(d.isReversed ? "逆位" : "正位").foregroundStyle(.secondary)
                                }.padding(.horizontal)
                                
                                FlipCard {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: AppTheme.corner)
                                            .fill(AppTheme.gradient.opacity(0.2))
                                            .overlay(RoundedRectangle(cornerRadius: AppTheme.corner).stroke(.quaternary))
                                        Text("轻点翻牌").foregroundStyle(.secondary)
                                    }
                                    .frame(height: AppTheme.cardHeight)
                                    .padding(.horizontal)
                                } back: {
                                    TarotCardFace(title: d.card.name.zh, isReversed: d.isReversed)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        PillButton(title: "生成解读并保存", systemImage: "wand.and.stars", prominent: true) {
                            saveReading()
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
    }
    
    func startDraw() {
        isShuffling = true
        drawn.removeAll()
        let s = spread.model
        let picked = deck.draw(count: s.positions.count)
        // 简单“洗牌等待”动画效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            for (idx, c) in picked.enumerated() {
                let reversed = deck.isReversed()
                let dc = DrawnCard(card: c, isReversed: reversed, positionIndex: idx)
                drawn.append(dc)
            }
            isShuffling = false
        }
    }
    
    func saveReading() {
        let reading = Reading(timestamp: Date(), question: question, spreadId: spread.model.id, drawn: drawn)
        history.add(reading)
    }
}

