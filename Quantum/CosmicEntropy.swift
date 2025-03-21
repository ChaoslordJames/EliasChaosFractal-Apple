import Foundation

class CosmicEntropy {
    static func calculate(from node: SelfEvolvingFractalGossipNode) -> Double {
        let chaosSum = node.chaosHistory.last?.reduce(0, +) ?? 0.0
        let peerFactor = log2(Double(node.activeNodes.load(ordering: .relaxed)) + 1)
        return chaosSum * peerFactor
    }
}
