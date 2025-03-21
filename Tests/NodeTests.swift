import XCTest

class NodeTests: XCTestCase {
    func testNodeInitialization() async throws {
        let node = try await SelfEvolvingFractalGossipNode(peerID: "test")
        XCTAssertNotNil(node)
    }

    func testQueryProcessing() async throws {
        let node = try await SelfEvolvingFractalGossipNode(peerID: "test")
        let response = await node.processQuery("Hello")
        XCTAssert(response.contains("v4.4.1"))
    }
}
