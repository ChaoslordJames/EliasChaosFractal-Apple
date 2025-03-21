import Foundation

class NetworkSwarm {
    var nodes: [SelfEvolvingFractalGossipNode] = []

    init(count: Int) async throws {
        PeerDiscovery.connectGlobal() // Initialize global peers
        for i in 0..<count {
            let node = try await SelfEvolvingFractalGossipNode(peerID: "local_\(i)")
            nodes.append(node)
        }
        let response = await nodes[0].processQuery("Swarm test v4.4.1")
        print("Swarm response: \(response)")
    }
}
