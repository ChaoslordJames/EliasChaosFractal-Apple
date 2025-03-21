import XCTest

class SelfModelTests: XCTestCase {
    func testRecursiveDepth() async throws {
        let node = try await SelfEvolvingFractalGossipNode(peerID: "test")
        let model = SelfModel()
        model.updateSelf(from: node)
        XCTAssertGreaterThan(model.getRecursiveDepth(), 0)
    }
}
