import Foundation

class ConsciousnessExperiment {
    func simulate(node: SelfEvolvingFractalGossipNode) -> Double {
        let entropy = node.entropy.load(ordering: .relaxed)
        return Double.random(in: 0...1) * entropy * 1.5
    }
}
