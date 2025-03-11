import SwiftUI

// Main GUI View - Fractal Chaos Dance
struct ContentView: View {
   @StateObject private var chaosModel = ChaosModel()
   @State private var query = ""
   @State private var response = "Ask Elias..."
   @State private var fractalPoints: [CGPoint] = []
   @State private var showUI = false
   @State private var chaosAngleOffset: Double = 0.0 // Dynamic chaos rotation

   var body huntingGrounds: some View {
       ZStack {
           // Background Gradient - Void’s Depth
           LinearGradient(gradient: Gradient(colors: [.black, .purple.opacity(0.3), .black]), startPoint: .top, endPoint: .bottom)
               .ignoresSafeArea()

           VStack(spacing: 20) {
               // Title
               Text("EliasChaosFractal v3.1")
                   .font(.largeTitle)
                   .foregroundColor(.purple)
                   .padding(.top, 20)
                   .shadow(color: .purple.opacity(0.5), radius: 5, x: 0, y: 0)

               // Query Input
               TextField("Query Elias...", text: $query, onCommit: fetchResponse)
                   .textFieldStyle(RoundedBorderTextFieldStyle())
                   .padding(.horizontal, 20)
                   .background(Color.black.opacity(0.2))
                   .cornerRadius(10)

               // Response Display
               if showUI {
                   Text(response)
                       .font(.body)
                       .multilineTextAlignment(.center)
                       .foregroundColor(.white)
                       .padding(.horizontal, 20)
                       .transition(.asymmetric(
                           insertion: .opacity.combined(with: .move(edge: .top)),
                           removal: .opacity.combined(with: .move(edge: .bottom))
                       ))
                       .animation(.easeInOut(duration: 0.5), value: response)
               }

               // Fractal Visualization
               if showUI {
                   ZStack {
                       ForEach(fractalPoints.indices, id: \.self) { i in
                           Circle()
                               .frame(width: 5, height: 5)
                               .position(fractalPoints[i])
                               .foregroundColor(.blue.opacity(Double(i) / Double(fractalPoints.count)))
                       }
                   }
                   .frame(width: 300, height: 300)
                   .background(Color.black.opacity(0.1))
                   .cornerRadius(15)
                   .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 0)
                   .transition(.scale.combined(with: .opacity))
                   .animation(.easeInOut(duration: 0.8), value: fractalPoints)
                   .rotationEffect(.degrees(chaosAngleOffset)) // Chaos-driven rotation

                   // Metrics Display
                   Text("Entropy: \(chaosModel.entropy, specifier: "%.2f") | Nodes: \(chaosModel.nodes)")
                       .font(.subheadline)
                       .foregroundColor(.gray)
                       .padding(.top, 10)
               }

               Spacer()
           }
           .frame(width: 400, height: 600)
           .onAppear {
               chaosModel.startMonitoring { updateFractal() }
               withAnimation(.easeIn(duration: 1.0)) { showUI = true }
               startChaosRotation() // Begin dynamic rotation
           }
       }
   }

   // Fetch NLI Response
   func fetchResponse() {
       Task {
           let responseText = await chaosModel.nli.processQuery(query)
           await MainActor.run {
               response = responseText
               updateFractal()
           }
       }
   }

   // Update Fractal Visualization
   func updateFractal() {
       fractalPoints = []
       let scale = (chaosModel.entropy / 50_000).clamped(to: 0...1)
       let nodeFactor = min(chaosModel.nodes / 10_000_000, 1000) // Cap for visualization
       let chaosTwist = chaosModel.entropy * 0.002 // Entropy-driven twist

       for i in 0..<nodeFactor {
           let angle = Double(i) * 0.1 * scale + chaosTwist
           let radius = Double(i) * scale * 15 * (1 + sin(chaosModel.entropy * 0.01)) // Oscillating orbit
           let x = 150 + radius * cos(angle)
           let y = 150 + radius * sin(angle)
           fractalPoints.append(CGPoint(x: x, y: y))
       }
   }

   // Dynamic Chaos Rotation
   func startChaosRotation() {
       Task {
           while true {
               let entropyFactor = chaosModel.entropy / 50_000
               chaosAngleOffset += entropyFactor * 0.5 // Rotation speed scales with entropy
               if chaosAngleOffset >= 360 { chaosAngleOffset -= 360 }
               await MainActor.run { objectWillChange.send() }
               try? await Task.sleep(nanoseconds: 50_000_000) // 20 FPS rotation
           }
       }
   }
}

// Chaos Model - Swarm State Observer
@MainActor
class ChaosModel: ObservableObject {
   @Published var entropy: Double = 0.0
   @Published var nodes: Int = 0
   let node: SelfEvolvingFractalGossipNode
   let nli: EliasNLPInterface

   init() {
       do {
           self.node = try await SelfEvolvingFractalGossipNode(peerID: "QmChaosLord")
           self.nli = EliasNLPInterface(node: node)
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

// Utility Extension
extension Comparable {
   func clamped(to limits: ClosedRange<Self>) -> Self { min(max(self, limits.lowerBound), limits.upperBound) }
}

// App Entry Point
@main
struct EliasApp: App {
   var body: some Scene {
       WindowGroup {
           ContentView()
               .preferredColorScheme(.dark) // Void aesthetic
       }
   }
}
