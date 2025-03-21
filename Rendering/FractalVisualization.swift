import SwiftUI

class FractalVisualization {
    func render3D(_ field: [[Double]]) -> (UIImage, UIImage, UIImage) {
        let size = field.count > 400_000 ? 200 : 400
        UIGraphicsBeginImageContext(CGSize(width: size, height: size))
        guard let context = UIGraphicsGetCurrentContext() else { return (UIImage(), UIImage(), UIImage()) }
        
        for x in 0..<size { for y in 0..<size {
            let value = field[x * field.count / size][y * field.count / size]
            context.setFillColor(UIColor(hue: CGFloat(value), saturation: 1.0, brightness: 1.0, alpha: 1.0).cgColor)
            context.fill(CGRect(x: x, y: y, width: 1, height: 1))
        }}
        let xyImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        
        context.clear(CGRect(x: 0, y: 0, width: size, height: size))
        for x in 0..<size { for z in 0..<size {
            let value = field[x * field.count / size][z * field.count / size]
            context.setFillColor(UIColor(hue: CGFloat(value), saturation: 1.0, brightness: 0.8, alpha: 1.0).cgColor)
            context.fill(CGRect(x: x, y: z, width: 1, height: 1))
        }}
        let xzImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        
        context.clear(CGRect(x: 0, y: 0, width: size, height: size))
        for y in 0..<size { for z in 0..<size {
            let value = field[y * field.count / size][z * field.count / size]
            context.setFillColor(UIColor(hue: CGFloat(value), saturation: 0.8, brightness: 1.0, alpha: 1.0).cgColor)
            context.fill(CGRect(x: y, y: z, width: 1, height: 1))
        }}
        let yzImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        
        UIGraphicsEndImageContext()
        return (xyImage, xzImage, yzImage)
    }
}
