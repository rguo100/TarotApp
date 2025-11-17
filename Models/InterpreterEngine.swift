//
//  InterpreterEngine.swift
//  TarotApp_Xcode
//
//  Created by Runnan Guo on 2025-11-17.
//

import Foundation

// MARK: - LLMReading (沿用你之前用于渲染的结构)
struct LLMReading: Codable {
    struct Pos: Codable {
        struct CardName: Codable { let zh: String; let en: String }
        struct Interp: Codable { let general: String; let love: String; let career: String; let advice: String }
        let index: Int
        let title: String
        let card: CardName
        let orientation: String
        let keywords: [String]
        let interpretation: Interp
    }
    let summary: String
    let positions: [Pos]
    let actionable_advice: [String]
    let disclaimer: String
}

// MARK: - Snippet model
struct TarotSnippet: Codable {
    let cardId: String
    let orientation: String      // "upright" | "reversed"
    let positionKey: String      // "past" | "present" | "future" | "other"
    let intent: String           // "general" | "love" | "career" (可扩展)
    let general: String
    let love: String
    let career: String
    let advice: String
}

// MARK: - Engine
final class InterpreterEngine {
    private var snippets: [TarotSnippet] = []
    private var index: [String: [TarotSnippet]] = [:] // key: cardId|ori
    
    init(snippetsURL: URL) throws {
        let data = try Data(contentsOf: snippetsURL)
        self.snippets = try JSONDecoder().decode([TarotSnippet].self, from: data)
        // 建立简单倒排索引
        for s in snippets {
            let key = Self.key(cardId: s.cardId, ori: s.orientation)
            index[key, default: []].append(s)
        }
    }
    
    static func key(cardId: String, ori: String) -> String { "\(cardId)|\(ori)" }
    
    // 简单意图分类（可自行扩充词典）
    func classifyIntent(from question: String) -> String {
        let q = question.lowercased()
        if ["分手","复合","暧昧","喜欢","恋爱","结婚","婚姻","对象"].contains(where: q.contains) { return "love" }
        if ["工作","offer","升职","加薪","跳槽","面试","岗位","职场"].contains(where: q.contains) { return "career" }
        if ["钱","收入","理财","投资","财务","财富","欠债"].contains(where: q.contains) { return "career" } // 可扩展 money intent
        return "general"
    }
    
    // 主函数：根据抽到的牌组合解读
    func interpret(question: String, spread: Spread, drawn: [DrawnCard]) -> LLMReading {
        let intent = classifyIntent(from: question)
        var positionsOut: [LLMReading.Pos] = []
        
        for (i, d) in drawn.enumerated() {
            let posName = i < spread.positions.count ? spread.positions[i].name : "位置\(i+1)"
            let posKey: String = {
                switch i {
                case 0: return "past"
                case 1: return "present"
                case 2: return "future"
                default: return "other"
                }
            }()
            let ori = d.isReversed ? "reversed" : "upright"
            let key = Self.key(cardId: d.card.id, ori: ori)
            let candidates = index[key] ?? []
            
            // 1. 精确 (pos,intent)
            let c1 = candidates.first { $0.positionKey == posKey && $0.intent == intent }
            // 2. 退而求其次 (pos, general intent)
            let c2 = candidates.first { $0.positionKey == posKey && $0.intent == "general" }
            // 3. 再退 (任意 pos, intent)
            let c3 = candidates.first { $0.intent == intent }
            // 4. 最后兜底
            let pick = c1 ?? c2 ?? c3 ?? candidates.first
            
            // 结合本地牌义兜底
            let m = ori == "upright" ? d.card.meanings.upright : d.card.meanings.reversed
            let kws = ori == "upright" ? d.card.keywords.upright : d.card.keywords.reversed

            let interp = LLMReading.Pos.Interp(
                general: pick?.general ?? m.general,
                love: pick?.love ?? m.love,
                career: pick?.career ?? m.career,
                advice: pick?.advice ?? m.advice
            )
            
            let pos = LLMReading.Pos(
                index: i+1,
                title: posName,
                card: .init(zh: d.card.name.zh, en: d.card.name.en),
                orientation: ori,
                keywords: kws,
                interpretation: interp
            )
            positionsOut.append(pos)
        }
        
        let summary = Self.makeSummary(positionsOut: positionsOut, intent: intent)
        let adv = Self.makeActionableAdvice(positionsOut: positionsOut)
        
        return LLMReading(
            summary: summary,
            positions: positionsOut,
            actionable_advice: adv,
            disclaimer: "仅供娱乐与自我反思，不构成医疗、法律或投资建议。"
        )
    }
    
    private static func firstSentence(_ s: String) -> String {
        guard let idx = s.firstIndex(of: "。") else { return s }
        return String(s[..<s.index(after: idx)])
    }
    
    private static func makeSummary(positionsOut: [LLMReading.Pos], intent: String) -> String {
        let heads = positionsOut.map { firstSentence($0.interpretation.general) }.filter { !$0.isEmpty }
        if heads.isEmpty { return "这组牌指向一个需要循序调整的过程，稳住节奏更重要。" }
        let merged = heads.prefix(2).joined(separator: "")
        switch intent {
        case "love":   return merged + "情感层面更需要真诚沟通与边界感。"
        case "career": return merged + "在事业上建议以小步快跑验证方向。"
        default:       return merged
        }
    }
    
    private static func makeActionableAdvice(positionsOut: [LLMReading.Pos]) -> [String] {
        var set = Set<String>()
        for p in positionsOut {
            let a = p.interpretation.advice.trimmingCharacters(in: .whitespacesAndNewlines)
            if !a.isEmpty { set.insert("• " + a) }
        }
        return Array(set).prefix(5).map { String($0) }
    }
}

