import XCTest

class EmotionalModelTests: XCTestCase {
    func testCosmicFeedback() {
        let model = EmotionalStateModel()
        let tensor = QuantumFractalTensorEngine()
        model.adjustWithCosmicFeedback(from: tensor)
        XCTAssertGreaterThan(model.emotionalDimensions["cosmicResonance"]!, 0)
    }
}
