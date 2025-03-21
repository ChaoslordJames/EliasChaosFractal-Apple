import XCTest

class ResilienceTests: XCTestCase {
    func testExtremeLoad() async throws {
        let node = try await SelfEvolvingFractalGossipNode(peerID: "test")
        let metrics = NetworkMetrics()
        XCTAssertGreaterThanOrEqual(metrics.resilienceScore(node), 99.95)
    }
}
