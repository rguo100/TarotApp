//
//  LocalTarotInterpreter.swift
//  TarotApp_Xcode
//
//  Created by Runnan Guo on 2025-11-17.
//
import Foundation

struct PolishedChunk: Identifiable, Hashable {
    let id = UUID()
    let index: Int            // 牌位序号，从 1 开始
    let title: String         // 牌位名
    let text: String          // 润色后的段落
}

final class LocalTarotInterpreter {
    static let shared = LocalTarotInterpreter()
    private init() {}
    
    enum Intent { case general, love, money, career }
    static func intent(from ui: IntentUI?) -> Intent? {
        guard let ui else { return nil }
        switch ui {
        case .love: return .love
        case .money: return .money
        case .career: return .career
        case .general: return .general
        }
    }
    
    private func classifyIntent(from q: String) -> Intent {
        let s = q.lowercased()
        if ["恋爱","暧昧","分手","复合","对象","婚姻","喜欢","告白"].contains(where: s.contains) { return .love }
        if["工作","面试","升职","加薪","跳槽","offer","项目","合作","职业"].contains(where: s.contains) { return .career }
        if ["钱","收入","理财","投资","财务","财富","欠债"].contains(where: s.contains) { return .career }
        return .general
    }

    // 用 spreadId 反解 Spread（和你现在的枚举保持一致）
    static func resolveSpread(by id: String) -> Spread {
        if id == "spread_one"   { return SpreadPreset.one.model }
        if id == "spread_three" { return SpreadPreset.three.model }
        if id == "spread_celtic"{ return SpreadPreset.celtic.model }
        // 兜底：把已保存的 drawn 长度作为 positions 数量
        return Spread(id: id, name: "牌阵", positions: (0..<3).map{ .init(id: $0, name: "位置 \($0+1)", hint: "") })
    }

    
    // 入口 A：直接用 Reading
    func generate(for reading: Reading) -> [PolishedChunk] {
        let spread = Self.resolveSpread(by: reading.spreadId)
        return generate(question: reading.question, spread: spread, drawn: reading.drawn)
    }

    // 入口 B：直接传 question + spread + drawn
    func generate(question: String,spread: Spread, drawn: [DrawnCard], explicitIntent: Intent? = nil) -> [PolishedChunk] {
        let implicit = classifyIntent(from: question)
        let intent = explicitIntent ?? implicit
        let hasQuestion = explicitIntent != nil || !question.trimmingCharacters(in: .whitespaces).isEmpty
        
        var chunks: [PolishedChunk] = []
        
        // MARK: 凯尔特十字
        if spread.id == "spread_celtic", drawn.count >= 10 {
            let names = ["现状","挑战","潜意识","显意识","过去","未来","自我","环境","希望/恐惧","结果"]

            var overviewParts: [String] = []
            for (i, d) in drawn.prefix(10).enumerated() {
                let oriText = d.isReversed ? "逆位" : "正位"
                let m = d.isReversed ? d.card.meanings.reversed : d.card.meanings.upright
                overviewParts.append("在【\(names[i])】，出现的是【\(d.card.name.zh)】（\(oriText)），它的提示是：\(m.general)")
            }

            let intro = [
                "凯尔特十字展开的是一张全景图，像把你此刻的处境层层剖开。",
                "这是一个比较全面的牌阵，它像在帮你梳理所有角度。"
            ].randomElement()!

            // 🔑 closingOptions 根据是否有问题来分
            let closingOptions: [String]
            if hasQuestion {
                switch intent {
                case .love:
                    closingOptions = [
                        "结合你的感情问题，这十张牌像拼图一样，既指出了挑战，也在提醒：\(drawn[9].card.name.zh) 所象征的未来能量——\(drawn[9].card.meanings.upright.general)。建议你：\(drawn[9].card.meanings.upright.advice)",
                        "在爱情层面，它们最终回应你的是：未来会显现 \(drawn[9].card.meanings.upright.general)，因此塔罗建议：\(drawn[9].card.meanings.upright.advice)"
                    ]
                case .career:
                    closingOptions = [
                        "从事业的角度来看，凯尔特十字回应了你的问题：最终的方向是 \(drawn[9].card.meanings.upright.general)。建议你在路上牢记：\(drawn[9].card.meanings.upright.advice)",
                        "关于你的工作/财富问题，十张牌整体串起来的提示是：\(drawn[9].card.meanings.upright.general)。而塔罗的结论是：\(drawn[9].card.meanings.upright.advice)"
                    ]
                default:
                    closingOptions = [
                        "结合你的提问，这十张牌的整体能量聚焦在『\(drawn[9].card.meanings.upright.general)』。建议你：\(drawn[9].card.meanings.upright.advice)",
                        "塔罗回应了你的问题：结尾的未来牌揭示 \(drawn[9].card.meanings.upright.general)，提醒你要 \(drawn[9].card.meanings.upright.advice)。"
                    ]
                }
            } else {
                closingOptions = [
                    "整体看下来，这十张牌像拼图一样，既指出了挑战，也给出了前行的方向。",
                    "所以不要慌张，把每一步都当作提醒，你就会慢慢走到答案那里。"
                ]
            }

            let closing = closingOptions.randomElement()!

            let story = """
            ✨ \(intro)

            \(overviewParts.joined(separator: "。\n"))

            \(closing)
            """

            chunks.append(.init(index: 0, title: hasQuestion ? "回应你的提问" : "凯尔特十字解读", text: story))
            return chunks
        }
            
        // MARK: 每日一抽
        if spread.id == "spread_one", let only = drawn.first {
            let oriText = only.isReversed ? "逆位" : "正位"
            let m = only.isReversed ? only.card.meanings.reversed : only.card.meanings.upright
            let kws = only.isReversed ? only.card.keywords.reversed : only.card.keywords.upright
            
            let mainText: String
            if hasQuestion {
                switch intent {
                case .love:
                    mainText = "关于感情，它说：\(m.love.isEmpty ? m.general : m.love)"
                case .career, .money:  // money 也走 career 文案池
                    mainText = "在工作/财富上，它提醒：\(m.career.isEmpty ? m.general : m.career)"
                default:
                    mainText = "它的整体寓意是：\(m.general)"
                }
            } else {
                mainText = """
                它的核心寓意是：\(m.general)
                在感情方面，它说：\(m.love)
                在事业方面，它提醒：\(m.career)
                """
            }

            // closing：按是否有 focus 选择你之前两套
            let closingOptions: [String]
            if hasQuestion {
                switch intent {
                case .love:
                    closingOptions = [
                        "结合你的感情方向，它在提醒：\(m.love)建议你：\(m.advice)",
                        "在爱情上，它回应你的关注：\(m.love)关键在于：\(m.advice)"
                    ]
                case .career, .money:
                    closingOptions = [
                        "结合你的工作/财富方向，它提示：\(m.career)接下来：\(m.advice)",
                        "在事业/金钱上，它的能量是：\(m.career)核心建议：\(m.advice)"
                    ]
                default:
                    closingOptions = [
                        "这张牌回应了你的关注点：\(m.general)最终建议：\(m.advice)",
                        "它的能量是『\(kws.first ?? m.general)』并提醒你：\(m.advice)"
                    ]
                }
            } else {
                closingOptions = [
                    "整体来看，这张牌的能量就是：\(m.general)，而它给你的建议是：\(m.advice)",
                    "关键词『\(kws.first ?? m.general)』很重要，带着它去实践：\(m.advice)"
                ]
            }

            let deep = """
            ✨ 你抽到的是：【\(only.card.name.zh)】（\(oriText)）

            关键词：\(kws.joined(separator: "、"))

            \(mainText)

            给你的具体建议是：\(m.advice)

            \(closingOptions.randomElement()!)
            """
            let title = hasQuestion ? "回应你的提问" : "整体解读"
            return [PolishedChunk(index: 0, title: title, text: deep)]
        }

        // MARK: 三张牌
        if spread.id == "spread_three", drawn.count == 3 {
            let past = drawn[0]
            let present = drawn[1]
            let future = drawn[2]

            func extract(_ d: DrawnCard, focus: Intent) -> (title: String, summary: String, advice: String) {
                let posName = d.isReversed ? "\(d.card.name.zh)(逆位)" : d.card.name.zh
                let m = d.isReversed ? d.card.meanings.reversed : d.card.meanings.upright

                let summary: String
                switch focus {
                case .love:   summary = m.love.isEmpty ? m.general : m.love
                case .career: summary = m.career.isEmpty ? m.general : m.career
                default:      summary = m.general
                }

                return (posName, summary, m.advice)
            }
            
            let p = extract(past, focus: intent)
            let n = extract(present, focus: intent)
            let f = extract(future, focus: intent)

            let futureAdvice = f.advice
            let futureSummary = f.summary
            let futureKeyword = futureSummary

            let openings = [
                "这三张牌像一条线，把你的故事慢慢展开。",
                "它们组合在一起，勾勒出一段旅程。",
                "三张牌给人的感觉，就像在讲一个连续的故事。"
            ]

            // 🔑 closingOptions 按 question 来分
            let closingOptions: [String]
            if hasQuestion {
                switch intent {
                case .love:
                    closingOptions = [
                        "结合你的感情问题，未来牌回应你：\(f.summary)建议是：\(f.advice)",
                        "在爱情上，它在提醒你：\(f.summary)核心是：\(f.advice)"
                    ]
                case .career:
                    closingOptions = [
                        "结合你的事业问题，未来牌提示：\(f.summary)接下来的方向是：\(f.advice)",
                        "在工作/财富方面，它回应你：\(f.summary)而关键建议是：\(f.advice)"
                    ]
                default:
                    closingOptions = [
                        "这三张牌回应了你的提问：\(f.summary)最终的建议是：\(f.advice)"
                    ]
                }
            } else {
                closingOptions = [
                    "最终，未来牌提示着你：\(f.advice)",
                    "整体串起来，其实在说：虽然面对\(f.summary)，但你要记得 \(f.advice)",
                    "如果给这三张牌一个结论，那就是『\(f.summary)』带着它去实践：\(f.advice)"
                ]
            }
            let closing = closingOptions.randomElement()!

            let story = """
                🔮 \(openings.randomElement()!)

                过去的【\(p.title)】讲述了：\(p.summary)它当时的信号是：\(p.advice)

                来到现在，出现了【\(n.title)】它在暗示：\(n.summary)它像在轻声对你说：\(n.advice)

                而未来的【\(f.title)】则象征着：\(f.summary)它为你点亮的方向是：\(f.advice)

                \(closing)
                """

            chunks.append(.init(index: 0, title: hasQuestion ? "回应你的提问" : "整体解读", text: story))
            return chunks
        }
        // MARK: 普通模式
        for (i, d) in drawn.enumerated() {
            let posName = i < spread.positions.count ? spread.positions[i].name : "位置 \(i+1)"
            let oriText = d.isReversed ? "逆位" : "正位"
            let m = d.isReversed ? d.card.meanings.reversed : d.card.meanings.upright
            let kws = d.isReversed ? d.card.keywords.reversed : d.card.keywords.upright

            let qLine: String
            if hasQuestion {
                switch intent {
                    case .love:   qLine = "结合你的感情问题，这张牌回应："
                    case .career: qLine = "针对事业/财富的提问，它提示："
                    default:      qLine = "关于你的问题，这张牌的启示是："
                }
            } else {
                qLine = ""
            }

            let paragraph = """
                \(posName) 抽到【\(d.card.name.zh)】（\(oriText)）。  
                \(qLine)\(m.general)  
                建议：\(m.advice)
            """
            chunks.append(.init(index: i+1, title: posName, text: paragraph))
        }
        return chunks
    }
}
