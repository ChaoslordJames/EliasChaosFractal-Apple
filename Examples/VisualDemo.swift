import SwiftUI

class VisualDemo {
    let visualization = FractalVisualization()
    let tensor = QuantumFractalTensorEngine()

    func runDemo() -> (UIImage, UIImage, UIImage) {
        let field = Array(repeating: Array(repeating: 0.5, count: 200), count: 200)
        return visualization.render3D(field)
    }
}
