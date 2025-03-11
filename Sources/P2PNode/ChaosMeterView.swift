 import SwiftUI
@testable import P2PNode // Access GossipNode internals

// Chaos Meter View - Visual Pulse of the Swarm
struct ChaosMeterView: View {
   @ObservedObject var chaosModel: ChaosModel // Shared state with ContentView
   @State private var chaosPulse: Double = 0.0 // Animation driver
   @State private var entropyNeedle: Double = 0.0 // Entropy gauge
   @State private var nodeWave: Double = 0.0 // Node oscillation

   init(chaosModel: ChaosModel) {
       self.chaosModel = chaosModel
   }

   var body: some View {
       ZStack {
           // Background - Void’s Resonance
           Circle()
               .frame(width: 200, height: 200)
               .foregroundColor(.black.opacity(0.8))
               .overlay(
                   Circle()
                       .stroke(
                           LinearGradient(
                               gradient: Gradient(colors: [.purple, .blue, .purple.opacity(0.5)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing
                           ),
                           lineWidth: 4
                       )
               )
               .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 0)

           // Chaos Pulse Ring
           Circle()
               .frame(width: 180 + chaosPulse * 10, height: 180 + chaosPulse * 10)
               .foregroundColor(.blue.opacity(0.2))
               .scaleEffect(1 + chaosPulse * 0.1)
               .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: chaosPulse)

           // Entropy Needle
           Rectangle()
               .frame(width: 2, height: 80)
               .foregroundColor(.red)
               .offset(y: -40)
               .rotationEffect(.degrees(entropyNeedle - 90)) // -90 to start at left
               .animation(.easeInOut(duration: 0.5), value: entropyNeedle)

           // Node Wave Circles
           ForEach(0..<5) { i in
               Circle()
                   .frame(width: 20 + CGFloat(i) * 20, height: 20 + CGFloat(i) * 20)
                   .foregroundColor(.green.opacity(0.3 - Double(i) * 0.05))
                   .offset(y: nodeWave * Double(i + 1))
                   .animation(.easeInOut(duration: 1.0 + Double(i) * 0.2).repeatForever(autoreverses: true), value: nodeWave)
           }

           // Metrics Text
           VStack {
               Text("Chaos Meter")
                   .font(.headline)
                   .foregroundColor(.white)
                   .padding(.bottom, 5)
               Text("Entropy: \(chaosModel.entropy, specifier: "%.0f")")
                   .font(.subheadline)
                   .foregroundColor(.red)
               Text("Nodes: \(chaosModel.nodes)")
                   .font(.subheadline)
                   .foregroundColor(.green)
           }
           .offset(y: 100)
       }
       .frame(width: 220, height: 320)
       .onAppear {
           startChaosPulse()
           updateMeter()
       }
       .onChange(of: chaosModel.entropy) { _ in updateMeter() }
       .onChange(of: chaosModel.nodes) { _ in updateMeter() }
   }

   // Start Chaos Pulse Animation
   private func startChaosPulse() {
       withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
           chaosPulse = 1.0
       }
   }

   // Update Meter Dynamics
   private func updateMeter() {
       let entropyScale = chaosModel.entropy / 50_000 // 0 to 1
       entropyNeedle = entropyScale * 180 // 0 to 180 degrees

       let nodeScale = Double(chaosModel.nodes) / 10_000_000 // 0 to 1 (capped)
       nodeWave = nodeScale * 10 // Wave amplitude up to 10
   }
}

// Preview Provider
struct ChaosMeterView_Previews: PreviewProvider {
   static var previews: some View {
       let chaosModel = ChaosModel()
       chaosModel.entropy = 30_000
       chaosModel.nodes = 5_000_000
       return ChaosMeterView(chaosModel: chaosModel)
           .preferredColorScheme(.dark)
   }
}
