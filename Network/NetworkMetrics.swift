import Foundation

class NetworkMetrics {
    func resilienceScore(_ node: SelfEvolvingFractalGossipNode) -> Double {
        let peerCount = Double(node.activeNodes.load(ordering: .relaxed))
        let score = min(peerCount / 5_000_000 * 100, 99.99)
        if score < 99.95 { print("Warning: Resilience dropping: \(score)%") }
        return score
    }

    func throughput(_ node: SelfEvolvingFractalGossipNode, queries: Int, seconds: Double) -> Double {
        return Double(queries) / seconds
    }
}
