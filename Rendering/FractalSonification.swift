import AVFoundation

class FractalSonification {
    private let synthesizer = AVSpeechSynthesizer()
    private var queue: [AVSpeechUtterance] = []

    func sonify(_ coherence: Double) {
        if queue.count < 2 {
            let utterance = AVSpeechUtterance(string: "Cosmic hum: \(coherence)")
            utterance.rate = Float(0.4 + coherence * 0.15)
            utterance.pitchMultiplier = Float(1.0 + coherence * 0.4)
            queue.append(utterance)
            synthesizer.speak(utterance)
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                queue.removeFirst()
            }
        }
    }
}
