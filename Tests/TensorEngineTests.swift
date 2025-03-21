import XCTest

class TensorEngineTests: XCTestCase {
    func testFieldUpdate() async throws {
        let node = try await SelfEvolvingFractalGossipNode(peerID: "test")
        let tensor = QuantumFractalTensorEngine()
        tensor.updateField(from: node)
        XCTAssertGreaterThan(tensor.cosmicEntropy, 0)
    }
}
