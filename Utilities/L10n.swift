import Foundation

enum L10n {
    // Home
    static var homeTitle: String { NSLocalizedString("home.title", comment: "") }
    static var homeAsk: String { NSLocalizedString("home.ask", comment: "") }
    static var homePlaceholder: String { NSLocalizedString("home.placeholder", comment: "") }
    static var homeEmptyTitle: String { NSLocalizedString("home.empty.title", comment: "") }
    static var homeEmptyCTA: String { NSLocalizedString("home.empty.cta", comment: "") }
    
    // Spreads / Buttons
    static var dailyOne: String { NSLocalizedString("spread.one", comment: "") }
    static var threeCards: String { NSLocalizedString("spread.three", comment: "") }
    static var celtic: String { NSLocalizedString("spread.celtic", comment: "") }
    static var generateAndSave: String { NSLocalizedString("btn.generate.save", comment: "") }
    
    // States / Labels
    static var shuffling: String { NSLocalizedString("state.shuffling", comment: "") }
    static var startDraw: String { NSLocalizedString("state.start.draw", comment: "") }
    static var upright: String { NSLocalizedString("state.upright", comment: "") }
    static var reversed: String { NSLocalizedString("state.reversed", comment: "") }
    static var share: String { NSLocalizedString("btn.share", comment: "") }
    
    // Accessibility
    static var a11yFlipCardLabel: String { NSLocalizedString("a11y.flip.label", comment: "") }
    static var a11yFlipCardHint: String { NSLocalizedString("a11y.flip.hint", comment: "") }
    static var a11yGenerateAndSaveLabel: String { NSLocalizedString("a11y.generate.save.label", comment: "") }
    static var a11yGenerateAndSaveHint: String { NSLocalizedString("a11y.generate.save.hint", comment: "") }
    
    // Disclaimer
    static var disclaimer: String { NSLocalizedString("disclaimer", comment: "") }
    
    // Result
    static var resultTitle: String { NSLocalizedString("result.title", comment: "") }
}

