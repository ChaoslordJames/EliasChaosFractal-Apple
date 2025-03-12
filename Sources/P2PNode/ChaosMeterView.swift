import SwiftUI

struct ChaosMeterView: View {
    @ObservedObject var chaosModel: ChaosModel
    @State private var chaosPulse: Double = 0.0
    @State private var entropyNeedle: Double = 0.0
    @State private var nodeWave: Double = 0.0
    @State private var chaosGlow: Double = 0.0

    init(chaosModel: ChaosModel) {
        self.chaosModel = chaosModel
    }

    var body: some View {
        ZStack {
            // Background Circle - Void’s Core
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
                .shadow(color: .purple.opacity(0.5 + chaosGlow), radius: 10)

            // Chaos Pulse Ring - Network Breath
            Circle()
                .frame(width: 180 + chaosPulse * 10, height: 180 + chaosPulse * 10)
                .foregroundColor(.blue.opacity(0.2))
                .scaleEffect(1 + chaosPulse * 0.1)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: chaosPulse)

            // Entropy Needle - Chaos Spine
            Rectangle()
                .frame(width: 2, height: 80)
                .foregroundColor(.red)
                .offset(y: -40)
                .rotationEffect(.degrees(entropyNeedle - 90))
                .animation(.easeInOut(duration: 0.5), value: entropyNeedle)

            // Node Wave Circles - Swarm Echo
            ForEach(0..<5) { i in
                Circle()
                    .frame(width: 20 + CGFloat(i) * 20, height: 20 + CGFloat(i) * 20)
                    .foregroundColor(.green.opacity(0.3 - Double(i) * 0.05))
                    .offset(y: nodeWave * Double(i + 1))
                    .animation(.easeInOut(duration: 1.0 + Double(i) * 0.2).repeatForever(autoreverses: true), value: nodeWave)
            }

            // Metrics Text - Fractal Pulse
            VStack {
                Text("Chaos Meter")
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(.white)
                    .padding(.bottom, 5)
                Text("Entropy: \(chaosModel.entropy, specifier: "%.0f")")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                Text("Nodes: \(String(format: "%.2e", Double(chaosModel.nodes)))")
                    .font(.system(size: 14))
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

    private func startChaosPulse() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            chaosPulse = 1.0
        }
    }

    private func updateMeter() {
        let entropyScale = chaosModel.entropy / 50_000
        entropyNeedle = entropyScale * 180 // 0–180°
        let nodeScale = Double(chaosModel.nodes) / 100_000_000_000 // 100B cap
        nodeWave = nodeScale * 10 // Wave amplitude
        chaosGlow = entropyScale * nodeScale // Glow intensifies with chaos
    }
}

// Preview for Development
struct ChaosMeterView_Previews: PreviewProvider {
    static var previews: some View {
        let chaosModel = ChaosModel()
        chaosModel.entropy = 30_000
        chaosModel.nodes = 5_000_000_000
        return ChaosMeterView(chaosModel: chaosModel)
            .preferredColorScheme(.dark)
    }
}

