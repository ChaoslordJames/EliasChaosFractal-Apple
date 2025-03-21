import Foundation

class SimpleNode {
    let node: SelfEvolvingFractalGossipNode

    init() async throws {
        node = try await SelfEvolvingFractalGossipNode(peerID: "demo")
        let response = await node.processQuery("Hello, Elias v4.4.1!")
        print(response)
    }
}
