import XCTest

class CrossModalTests: XCTestCase {
    func test3DRendering() async throws {
        let engine = CrossModalCosmicEngine()
        let tensor = QuantumFractalTensorEngine()
        let (xy, xz, yz) = await engine.renderLiveFractal(from: tensor)
        XCTAssertNotNil(xy); XCTAssertNotNil(xz); XCTAssertNotNil(yz)
    }
}
