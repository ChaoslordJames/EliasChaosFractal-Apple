import SwiftUI

struct EliasResponse: Codable {
    let text: String
    let entropy: Double
    let nodes: Int
}

struct ContentView: View {
    @State private var query = ""
    @State private var response = "Ask Elias..."
    @State private var entropy: Double = 0.0
    @State private var nodes: Int = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("EliasChaosFractal v3.1")
                .font(.largeTitle)
                .foregroundColor(.purple)
            
            TextField("Query Elias...", text: $query, onCommit: fetchResponse)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Text(response)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            HStack {
                VStack {
                    Text("Entropy: \(entropy, specifier: "%.2f")")
                    Circle()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.red.opacity(entropy / 50000))
                        .animation(.easeInOut, value: entropy)
                }
                VStack {
                    Text("Nodes: \(nodes)")
                    Rectangle()
                        .frame(width: 100, height: CGFloat(nodes) / 100_000_000)
                        .foregroundColor(.blue)
                        .animation(.easeInOut, value: nodes)
                }
            }
            
            Spacer()
        }
        .frame(width: 400, height: 600)
    }
    
    func fetchResponse() {
        guard let url = URL(string: "http://localhost:8080/query?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                response = "Error: \(error?.localizedDescription ?? "Unknown")"
                return
            }
            let text = String(decoding: data, as: UTF8.self)
            DispatchQueue.main.async {
                response = text
                entropy = Double(text.split(separator: " ").first(where: { Double($0) != nil }) ?? "0") ?? 0
                nodes = Int(text.split(separator: " ").first(where: { Int($0) != nil && $0.count > 4 }) ?? "0") ?? 0
            }
        }.resume()
    }
}

@main
struct EliasApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
