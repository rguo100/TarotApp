import SwiftUI

struct HomeView: View {
    @EnvironmentObject var deck: TarotDeck
    @EnvironmentObject var history: ReadingHistoryStore
    @State private var question: String = ""
    @State private var showingSettings = false
    @State private var gotoOne = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("今天想问点什么？").font(.title2).bold()
                    TextField("输入问题（可留空）", text: $question)
                        .textFieldStyle(.roundedBorder)
                }.padding(.horizontal)
                
                HStack {
                    NavigationLink(value: NavTarget.draw(spread: .one)) {
                        BigButton(title: "每日一抽")
                    }
                    NavigationLink(value: NavTarget.draw(spread: .three)) {
                        BigButton(title: "三张牌")
                    }
                }.padding(.horizontal)
                
                NavigationLink(value: NavTarget.draw(spread: .celtic)) {
                    BigButton(title: "凯尔特十字")
                        .padding(.horizontal)
                }

                NavigationLink(
                    destination: DrawView(question: "", spread: .one),
                    isActive: $gotoOne
                ) { EmptyView() }
                
                if !history.readings.isEmpty {
                    List {
                        Section("历史记录") {
                            ForEach(history.readings) { r in
                                NavigationLink(value: NavTarget.detail(reading: r)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(r.question.isEmpty ? "未命名问题" : r.question).font(.headline)
                                        Text(r.timestamp, style: .date).font(.caption)
                                    }
                                }
                            }.onDelete(perform: history.delete)
                        }
                    }.listStyle(.insetGrouped)
                } else {
                    Spacer()
                    EmptyStateView(
                        title: L10n.homeEmptyTitle,
                        actionTitle: L10n.homeEmptyCTA
                    ) {
                        gotoOne = true
                    }
                    Spacer()
                }
            }
            .navigationTitle("塔罗")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingSettings.toggle() } label: { Image(systemName: "gear") }
                }
            }
            .navigationDestination(for: NavTarget.self) { target in
                switch target {
                case .draw(let spread): DrawView(question: question, spread: spread)
                case .detail(let reading): ResultView(reading: reading)
                }
            }
            .sheet(isPresented: $showingSettings) { SettingsView() }
        }
    }
}

enum NavTarget: Hashable {
    case draw(spread: SpreadPreset)
    case detail(reading: Reading)
}

struct BigButton: View {
    let title: String
    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

enum SpreadPreset: String, CaseIterable {
    case one, three, celtic
    
    var model: Spread {
        switch self {
        case .one:
            return Spread(
                id: "spread_one",
                name: "每日一抽",
                positions: [ .init(id: 0, name: "此刻能量", hint: "这一刻的核心信息") ]
            )
        case .three:
            return Spread(
                id: "spread_three",
                name: "三张牌",
                positions: [
                    .init(id: 0, name: "过去/原因", hint: "促成当下的因素"),
                    .init(id: 1, name: "现在/状态", hint: "当前正在发生"),
                    .init(id: 2, name: "未来/趋势", hint: "可能的走向")
                ]
            )
        case .celtic:
            return Spread(
                id: "spread_celtic",
                name: "凯尔特十字",
                positions: [
                    .init(id: 0, name: "现状", hint: ""),
                    .init(id: 1, name: "挑战", hint: ""),
                    .init(id: 2, name: "潜意识", hint: ""),
                    .init(id: 3, name: "显意识", hint: ""),
                    .init(id: 4, name: "过去", hint: ""),
                    .init(id: 5, name: "未来", hint: ""),
                    .init(id: 6, name: "自我", hint: ""),
                    .init(id: 7, name: "环境", hint: ""),
                    .init(id: 8, name: "希望/恐惧", hint: ""),
                    .init(id: 9, name: "结果", hint: "")
                ]
            )
        }
    }
}

