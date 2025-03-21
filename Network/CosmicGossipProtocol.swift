import Foundation

class CosmicGossipProtocol {
    func propagateState(_ state: State, to peers: [String], churn: Double) async -> Bool {
        let replicationFactor = 16 + Int(churn * 100 * 0.09) // Up to 25
        let successfulPeers = peers.filter { _ in Double.random(in: 0...1) > churn }
        return successfulPeers.count >= Int(Double(replicationFactor) * 0.8)
    }
}

struct State {
    let cid: String
    let encrypted: String
}
