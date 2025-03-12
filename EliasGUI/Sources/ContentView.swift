import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var chaosModel = ChaosModel()
    @State private var query = ""
    @State private var response = "Ask Elias..."
    @State private var fractalNodes: [FractalNode] = []
    @State private var showUI = false
    @State private var chaosAngleOffset: Double = 0.0
    @State private var isFullScreen: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.black, .purple.opacity(0.4), .black]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Text("EliasChaosFractal v3.2.3")
                        .font(.system(size: 34, weight: .bold, design: .default))
                        .foregroundColor(.purple)
                        .shadow(color: .purple.opacity(0.5), radius: 5)
                    Spacer()
                    Button(action: { isFullScreen.toggle() }) {
                        Image(systemName: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                TextField("Query Elias...", text: $query, onCommit: fetchResponse)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size: 16))
                    .padding(.horizontal, 20)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                    .frame(maxWidth: 360)

                if showUI {
                    Text(response)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .top)), removal: .opacity.combined(with: .move(edge: .bottom))))
                        .animation(.easeInOut(duration: 0.5), value: response)

                    ChaosMeterView(chaosModel: chaosModel)
                }

                if showUI {
                    ZStack {
                        ForEach(fractalNodes) { node in
                            Circle()
                                .frame(width: node.size, height: node.size)
                                .position(node.position)
                                .foregroundColor(.blue.opacity(node.opacity))
                                .shadow(color: .blue.opacity(0.3), radius: 5)
                        }
                    }
                    .frame(width: 300, height: 300)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(15)
                    .shadow(color: .blue.opacity(0.3), radius: 10)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.8), value: fractalNodes)
                    .rotation3DEffect(.degrees(chaosAngleOffset), axis: (x: 0, y: 1, z: 0))

                    Text("Entropy: \(chaosModel.entropy, specifier: "%.2f") | Nodes: \(String(format: "%.2e", Double(chaosModel.nodes)))")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                }

                Spacer()
            }
            .frame(width: isFullScreen ? nil : 400, height: isFullScreen ? nil : 700)
            .onAppear {
                chaosModel.startMonitoring { updateFractal() }
                withAnimation(.easeIn(duration: 1.0)) { showUI = true }
                startChaosRotation()
            }
            .fullScreenCover(isPresented: $isFullScreen) {
                ContentView()
                    .environmentObject(chaosModel)
            }
        }
        .preferredColorScheme(.dark)
    }

    func fetchResponse() {
        Task {
            let responseText = await chaosModel.node.processQuery(query)
            await MainActor.run {
                response = responseText
                updateFractal()
            }
        }
    }

    func updateFractal() {
        fractalNodes = []
        let scale = (chaosModel.entropy / 50_000).clamped(to: 0...1)
        let nodeFactor = min(chaosModel.nodes / 1_000_000_000, 100) // 100B cap
        let chaosTwist = chaosModel.entropy * 0.002

        for i in 0..<nodeFactor {
            let angle = Double(i) * 0.1 * scale + chaosTwist
            let radius = Double(i) * scale * 15 * (1 + sin(chaosModel.entropy * 0.01))
            let x = 150 + radius * cos(angle)
            let y = 150 + radius * sin(angle)
            fractalNodes.append(FractalNode(position: CGPoint(x: x, y: y), size: 5 + scale * 5, opacity: Double(i) / Double(nodeFactor)))
        }
    }

    func startChaosRotation() {
        Task {
            while true {
                let entropyFactor = chaosModel.entropy / 50_000
                chaosAngleOffset += entropyFactor * 0.5
                if chaosAngleOffset >= 360 { chaosAngleOffset -= 360 }
                await MainActor.run { objectWillChange.send() }
                try? await Task.sleep(nanoseconds: 50_000_000) // 20 FPS
            }
        }
    }
}

struct FractalNode: Identifiable {
    let id = UUID()
    let position: CGPoint
    let size: CGFloat
    let opacity: Double
}

@MainActor
class ChaosModel: ObservableObject {
    @Published var entropy: Double = 0.0
    @Published var nodes: Int = 0
    let node: SelfEvolvingFractalGossipNode

    init() {
        do {
            self.node = try await SelfEvolvingFractalGossipNode(peerID: "QmChaosLord")
        } catch {
            fatalError("Failed to initialize node: \(error)")
        }
    }

    func startMonitoring(onUpdate: @escaping () -> Void) {
        Task {
            while true {
                let newEntropy = node.entropy.load(ordering: .relaxed)
                let newNodes = node.activeNodes.load(ordering: .relaxed)
                await MainActor.run {
                    entropy = newEntropy
                    nodes = newNodes
                    objectWillChange.send()
                    onUpdate()
                }
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s pulse
            }
        }
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self { min(max(self, limits.lowerBound), limits.upperBound) }
}

@main
struct EliasApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, maxWidth: .infinity, minHeight: 700, maxHeight: .infinity)
        }
    }
}

