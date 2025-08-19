import Foundation
import Combine
import Speech

enum RecordingState {
    case idle
    case recording
    case paused
    // case finished
}

class RecordingViewModel: ObservableObject {
    @Published var transcription: String = ""
    @Published var state: RecordingState = .idle
    
    private let speechService = SpeechService()
    private let appState: AppState

    init(appState: AppState = .shared) {
        self.appState = appState

        // Bind SpeechService transcription updates
        speechService.$transcription
            .receive(on: DispatchQueue.main)
            .assign(to: &$transcription)
    }
    
    // MARK: - Permission Handling
    func currentPermissionStatus() -> SFSpeechRecognizerAuthorizationStatus {
        SFSpeechRecognizer.authorizationStatus()
    }
    
    func requestPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
        let status = currentPermissionStatus()
        switch status {
        case .authorized:
            completion(true)
        case .denied, .restricted:
            completion(false)
        case .notDetermined:
            SFSpeechRecognizer.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized)
                }
            }
        @unknown default:
            completion(false)
        }
    }
    
    // MARK: - Recording Controls
    func startRecording() {
        do {
            try speechService.startRecording()
            state = .recording
        } catch {
            print("❌ Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func pauseRecording() {
        speechService.pauseRecording()
        state = .paused
    }
    
    func resumeRecording() {
        do {
            try speechService.resumeRecording()
            state = .recording
        } catch {
            print("❌ Failed to resume recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        speechService.stopRecording()
        // state = .finished
        // We’re skipping the finished step for now
    }
    
    // MARK: - Submit (non-blocking)
    /// Kicks off the submit and returns immediately.
    func submitTranscript() {
        let text = transcription.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            // Nothing to send, flip off just in case
            DispatchQueue.main.async { self.appState.isProcessingTranscript = false }
            return
        }

        // Show global loader
        DispatchQueue.main.async { self.appState.isProcessingTranscript = true }

        // Fire-and-forget so the UI can dismiss right away
        Task.detached {
            do {
                let payload = ["transcript": text]
                let body = try JSONEncoder().encode(payload)

                // Send transcript to backend (auth required)
                let _: EmptyResponse = try await APIClient.shared.request(
                    endpoint: "/transcript",
                    method: "POST",
                    body: body,
                    requiresAuth: true
                )
            } catch {
                print("❌ Failed to submit transcript:", error.localizedDescription)
            }

            // Always hide loader when done
            DispatchQueue.main.async {
                self.appState.isProcessingTranscript = false
            }
        }
    }
}
