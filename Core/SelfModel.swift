import Foundation

class SelfModel {
    var selfState: [String: Double] = ["entropy": 0.0, "valence": 0.0]
    var quantumState: [String: Double] = ["cosmicEntropy": 0.0]
    private var cachedDepth: Double?
    private var lastUpdate = Date.distantPast

    func updateSelf(from node: SelfEvolvingFractalGossipNode) {
        selfState["entropy"] = node.entropy.load(ordering: .relaxed)
        selfState["valence"] = node.emotionalStateModel.getCurrentValence()
        quantumState["cosmicEntropy"] = CosmicEntropy.calculate(from: node)
    }

    func getRecursiveDepth() -> Double {
        if let cached = cachedDepth, Date().timeIntervalSince(lastUpdate) < 5 { return cached }
        cachedDepth = log(1 + selfState.count + quantumState.count * 0.3)
        lastUpdate = Date()
        return cachedDepth!
    }
}
