import Foundation
import Speech
import AVFoundation
import Combine
import SwiftUI

class SpeechService: NSObject, ObservableObject {
    // Public state
    @Published var transcription: String = ""
    @Published var isAuthorized: Bool = false
    @Published var showPermissionAlert: Bool = false

    // Speech & audio
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    // Internal state
    private var accumulatedText: String = ""        // preserves text across pause/resume
    private var isSessionConfigured = false
    private var isPaused: Bool = false

    override init() {
        super.init()
        checkAuthorizationStatus()
    }

    // MARK: - Permissions
    private func checkAuthorizationStatus() {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            isAuthorized = true
        case .notDetermined, .denied, .restricted:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }

    func requestPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
        let status = SFSpeechRecognizer.authorizationStatus()
        switch status {
        case .authorized:
            isAuthorized = true
            completion(true)

        case .notDetermined:
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    self.isAuthorized = (status == .authorized)
                    completion(self.isAuthorized)
                }
            }

        case .denied, .restricted:
            DispatchQueue.main.async {
                self.showPermissionAlert = true
                completion(false)
            }

        @unknown default:
            completion(false)
        }
    }
    // MARK: - Audio session
    private func ensureAudioSession() throws {
        guard !isSessionConfigured else { return }
        let session = AVAudioSession.sharedInstance()
        // Use playAndRecord to allow speaker output while recording if you add TTS later.
        try session.setCategory(.playAndRecord,
                                mode: .measurement,
                                options: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers])
        try session.setActive(true, options: .notifyOthersOnDeactivation)
        isSessionConfigured = true
    }

    // MARK: - Public controls
    /// Start a fresh recording. If `reset` is false, we resume and append.
    func startRecording(reset: Bool = true) throws {
        try ensureAudioSession()

        if reset {
            accumulatedText = ""
            transcription = ""
        } else {
            // keep accumulatedText/transcription
        }

        try startEngineWithNewTask()
        isPaused = false
    }

    func pauseRecording() {
        // End current task cleanly but keep accumulated text so we can resume and append.
        endCurrentTask(keepAccumulated: true)
        isPaused = true
    }

    func resumeRecording() throws {
        guard isPaused else { return }
        try ensureAudioSession()
        try startEngineWithNewTask() // fresh request/task & tap
        isPaused = false
    }

    func stopRecording() {
        // Finalize and keep whatever we have
        endCurrentTask(keepAccumulated: true)
        isPaused = false
    }

    // MARK: - Core wiring
    private func startEngineWithNewTask() throws {
        // If anything is lingering, end it before starting a fresh task
        endCurrentTask(keepAccumulated: true)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        // If you want, enable on-device when supported:
        // if #available(iOS 13.0, *) { request.requiresOnDeviceRecognition = true }

        recognitionRequest = request

        // Install input tap
        let inputNode = audioEngine.inputNode
        let bus: AVAudioNodeBus = 0
        let inputFormat = inputNode.inputFormat(forBus: bus)

        inputNode.removeTap(onBus: bus)
        inputNode.installTap(onBus: bus, bufferSize: 2048, format: inputFormat) { [weak self] buffer, _ in
            guard let self = self, let req = self.recognitionRequest else { return }
            req.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                let partial = result.bestTranscription.formattedString

                // Merge partial with accumulated
                DispatchQueue.main.async {
                    if self.accumulatedText.isEmpty {
                        self.transcription = partial
                    } else {
                        if partial.isEmpty {
                            self.transcription = self.accumulatedText
                        } else {
                            let joiner = self.accumulatedText.hasSuffix(" ") ? "" : " "
                            self.transcription = self.accumulatedText + joiner + partial
                        }
                    }
                }

                // If engine decides this chunk is final, fold it into accumulated
                if result.isFinal {
                    self.accumulatedText = self.transcription
                }
            }

            if let _ = error {
                // Close out task; keep what we have so far
                self.endCurrentTask(keepAccumulated: true)
            }
        }
    }

    private func endCurrentTask(keepAccumulated: Bool) {
        // Remove tap & stop engine
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)

        if audioEngine.isRunning {
            audioEngine.stop()
        }

        // End/Cancel
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil

        // Preserve or clear
        if keepAccumulated {
            accumulatedText = transcription
        } else {
            accumulatedText = ""
            transcription = ""
        }
    }
}
