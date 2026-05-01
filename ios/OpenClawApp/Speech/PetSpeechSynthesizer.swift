import AVFoundation

final class PetSpeechSynthesizer {
    private let synthesizer = AVSpeechSynthesizer()

    func speakTeachingEcho(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.38
        utterance.pitchMultiplier = 1.45
        utterance.volume = 0.8
        synthesizer.speak(utterance)
    }

    func chirp(_ text: String = "pi") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.52
        utterance.pitchMultiplier = 1.8
        utterance.volume = 0.55
        synthesizer.speak(utterance)
    }
}
