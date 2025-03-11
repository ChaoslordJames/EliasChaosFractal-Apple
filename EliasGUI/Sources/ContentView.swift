struct ContentView: View {
    @State private var query = ""
    @State private var response = "Ask Elias..."
    @State private var entropy: Double = 0.0
    @State private var nodes: Int = 0
    @State private var fractalPoints: [CGPoint] = []

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

            ZStack {
                ForEach(0..<fractalPoints.count, id: \.self) { i in
                    Circle()
                        .frame(width: 5, height: 5)
                        .position(fractalPoints[i])
                        .foregroundColor(.blue.opacity(Double(i) / Double(fractalPoints.count)))
                }
            }
            .frame(width: 300, height: 300)
            .background(Color.black.opacity(0.1))
            .animation(.easeInOut(duration: 1.0), value: fractalPoints)

            Text("Entropy: \(entropy, specifier: "%.2f") | Nodes: \(nodes)")
        }
        .frame(width: 400, height: 600)
        .onAppear(perform: updateFractal)
    }

    func fetchResponse() {
        guard let url = URL(string: "http://localhost:8080/query?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            let text = String(decoding: data, as: UTF8.self)
            DispatchQueue.main.async {
                response = text
                entropy = Double(text.split(separator: " ").first(where: { Double($0) != nil }) ?? "0") ?? 0
                nodes = Int(text.split(separator: " ").first(where: { Int($0) != nil && $0.count > 4 }) ?? "0") ?? 0
                updateFractal()
            }
        }.resume()
    }

    func updateFractal() {
        fractalPoints = []
        let scale = min(entropy / 50_000, 1.0)
        for i in 0..<nodes / 10_000_000 {
            let angle = Double(i) * 0.1 * scale
            let radius = Double(i) * scale * 10
            let x = 150 + radius * cos(angle)
            let y = 150 + radius * sin(angle)
            fractalPoints.append(CGPoint(x: x, y: y))
        }
    }
}
