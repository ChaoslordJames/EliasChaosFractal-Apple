import XCTest

class SonificationTests: XCTestCase {
    func testSonify() {
        let sonification = FractalSonification()
        sonification.sonify(0.5)
    }
}
