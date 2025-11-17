import Foundation

struct TarotCard: Identifiable, Codable, Hashable {
    let id: String
    let name: LocalizedName
    let arcana: String
    let suit: String?
    let number: Int?
    let keywords: Keywords
    let meanings: Meanings
    let image: CardImage
    
    struct LocalizedName: Codable, Hashable {
        let zh: String
        let en: String
    }
    
    struct Keywords: Codable, Hashable {
        let upright: [String]
        let reversed: [String]
    }
    
    struct Meanings: Codable, Hashable {
        let upright: MeaningDetail
        let reversed: MeaningDetail
        
        struct MeaningDetail: Codable, Hashable {
            let general: String
            let love: String
            let career: String
            let advice: String
        }
    }
    
    struct CardImage: Codable, Hashable {
        let assetName: String
        let attribution: String?
    }
}

struct Spread: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let positions: [Position]
    
    struct Position: Identifiable, Codable, Hashable {
        let id: Int
        let name: String
        let hint: String
    }
}

struct DrawnCard: Identifiable, Codable, Hashable {
    let id = UUID()
    let card: TarotCard
    let isReversed: Bool
    let positionIndex: Int
}

struct Reading: Identifiable, Codable, Hashable {
    let id = UUID()
    let timestamp: Date
    let question: String
    let spreadId: String
    let drawn: [DrawnCard]
    var notes: String = ""
}

