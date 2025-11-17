import Foundation
import SwiftUI

final class TarotDeck: ObservableObject {
    @Published private(set) var cards: [TarotCard] = []
    @AppStorage("uprightProbability") var uprightProbability: Double = 0.5
    
    init() { loadDeck() }
    
    func loadDeck() {
        // 从 Bundle 读取 JSON（先用模板，后续填满 78 张）
        if let url = Bundle.main.url(forResource: "cards_template", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let root = try JSONDecoder().decode(DeckRoot.self, from: data)
                self.cards = root.cards
            } catch {
                print("Failed to load deck: \(error)")
            }
        } else {
            print("cards_template.json not found in bundle; using empty deck.")
        }
    }
    
    func draw(count: Int) -> [TarotCard] {
        guard count > 0 else { return [] }
        return Array(cards.shuffled().prefix(count))
    }
    
    func isReversed() -> Bool {
        // 根据“正位概率”决定正/逆位（prob 指正位概率）
        return Double.random(in: 0...1) > uprightProbability
    }
    
    private struct DeckRoot: Codable {
        let meta: Meta
        let cards: [TarotCard]
        struct Meta: Codable { let version: String; let language: String; let license: String }
    }
}

final class ReadingHistoryStore: ObservableObject {
    @Published private(set) var readings: [Reading] = []
    
    func add(_ reading: Reading) {
        readings.insert(reading, at: 0)
        save()
    }
    
    func delete(at offsets: IndexSet) {
        readings.remove(atOffsets: offsets)
        save()
    }
    
    private func save() {
        let url = Self.fileURL()
        do {
            let data = try JSONEncoder().encode(readings)
            try data.write(to: url)
        } catch {
            print("Failed to save history: \(error)")
        }
    }
    
    private func load() {
        let url = Self.fileURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            let list = try JSONDecoder().decode([Reading].self, from: data)
            self.readings = list
        } catch {
            print("Failed to load history: \(error)")
        }
    }
    
    static func fileURL() -> URL {
        let fm = FileManager.default
        let doc = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        return doc.appendingPathComponent("readings.json")
    }
    
    init() { load() }
}

