import XCTest

class GossipProtocolTests: XCTestCase {
    func testStatePropagation() async {
        let gossip = CosmicGossipProtocol()
        let state = State(cid: "1", encrypted: "data")
        let peers = (0..<1000).map { "p\($0)" }
        let success = await gossip.propagateState(state, to: peers, churn: 0.5)
        XCTAssertTrue(success)
    }
}
