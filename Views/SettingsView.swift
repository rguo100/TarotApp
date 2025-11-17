import SwiftUI

struct SettingsView: View {
    @AppStorage("uprightProbability") var uprightProbability: Double = 0.5
    @State private var showAttribution = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("解读设置") {
                    VStack(alignment: .leading) {
                        Text("正位概率：\(Int(uprightProbability*100))%")
                        Slider(value: $uprightProbability, in: 0...1, step: 0.05)
                    }
                    Text("将概率设为 0.5 常见；你也可以根据偏好调整。")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Section("关于与版权") {
                    Button("查看素材来源与许可证") { showAttribution = true }
                }
                Section("隐私") {
                    NavigationLink("隐私政策") { PolicyView(fileName: "privacy_policy_zh") }
                    NavigationLink("免责声明") { PolicyView(fileName: "disclaimer_zh") }
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showAttribution) {
                Text("请在此处列出图片/字体/音频等素材来源与许可证。")
                    .padding()
            }
        }
    }
}

struct PolicyView: View {
    let fileName: String
    var body: some View {
        ScrollView {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "md"),
               let text = try? String(contentsOf: url) {
                Text(text).padding()
            } else {
                Text("文档未找到。请将 \(fileName).md 加入项目 Bundle。").padding()
            }
        }
        .navigationTitle("文档")
        .navigationBarTitleDisplayMode(.inline)
    }
}

