@main
struct TarotApp: App {
    @StateObject private var deck = TarotDeck()
    @StateObject private var history = ReadingHistoryStore()
    @AppStorage("hasOnboarded") var hasOnboarded = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasOnboarded {
                    HomeView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(deck)
            .environmentObject(history)
        }
    }
}
