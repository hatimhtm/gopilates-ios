import Foundation
import AVFoundation

// MARK: - Audio Manager (Singleton)

class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()

    nonisolated(unsafe) private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking: Bool = false

    /// The preferred female French voice identifier
    /// iOS has several French voices. We explicitly pick a female one.
    private var femaleVoice: AVSpeechSynthesisVoice? {
        // Priority order of female French voices available on iOS:
        // 1. "Aurélie" (enhanced) — com.apple.voice.enhanced.fr-FR.Aurelie
        // 2. "Amélie" (Canadian French, very natural) — com.apple.ttsbundle.Amelie-compact
        // 3. "Thomas" is male, skip it
        // 4. Fallback to any fr-FR voice

        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        let frenchFemaleVoices = allVoices.filter {
            $0.language.hasPrefix("fr") && $0.gender == .female
        }

        // Prefer enhanced quality voices
        if let enhanced = frenchFemaleVoices.first(where: { $0.quality == .enhanced }) {
            return enhanced
        }

        // Then any female French voice
        if let female = frenchFemaleVoices.first {
            return female
        }

        // Absolute fallback: any French voice
        return AVSpeechSynthesisVoice(language: "fr-FR")
    }

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: - Audio Session Setup

    func setupSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                options: [.duckOthers, .interruptSpokenAudioAndMixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[AudioManager] Audio session setup error: \(error.localizedDescription)")
        }
    }

    func deactivateSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("[AudioManager] Audio session deactivation error: \(error.localizedDescription)")
        }
    }

    // MARK: - Speech

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = femaleVoice
        utterance.rate = 0.48  // Safe speed
        utterance.pitchMultiplier = 1.15  // Safe pitch
        utterance.volume = 0.85  // Safe volume
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.2

        // Stop any current speech before starting new one
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .word)
        }

        print("🔊 TTS Speak: '\(text)'")
        synthesizer.speak(utterance)
    }

    /// Speak with a specific tone — softer for encouragement, normal for instructions
    func speakEncouragement(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = femaleVoice
        utterance.rate = 0.45
        utterance.pitchMultiplier = 1.2
        utterance.volume = 0.8
        utterance.preUtteranceDelay = 0.2
        utterance.postUtteranceDelay = 0.3

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .word)
        }

        print("🔊 TTS Encouragement: '\(text)'")
        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension AudioManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = true }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = false }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = false }
    }
}
