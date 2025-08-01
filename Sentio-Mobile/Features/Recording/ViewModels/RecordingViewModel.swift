import Foundation
import Combine
import Speech

enum RecordingState {
    case idle
    case recording
    case paused
    case finished
}

class RecordingViewModel: ObservableObject {
    @Published var transcription: String = ""
    @Published var state: RecordingState = .idle
    
    private let speechService = SpeechService()
    
    init() {
        // Bind SpeechService transcription updates
        speechService.$transcription
            .receive(on: DispatchQueue.main)
            .assign(to: &$transcription)
    }
    
    // MARK: - Permission Handling
    func currentPermissionStatus() -> SFSpeechRecognizerAuthorizationStatus {
        return SFSpeechRecognizer.authorizationStatus()
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
        state = .finished
    }
    
    // MARK: - Submit Transcript
    func submitTranscript(completion: @escaping () -> Void) {
        Task {
            do {
                let payload = ["transcript": transcription]
                let body = try JSONEncoder().encode(payload)
                
                // Send transcript to backend
                let _: EmptyResponse = try await APIClient.shared.request(
                    endpoint: "/transcript",
                    method: "POST",
                    body: body,
                    requiresAuth: true
                )
                
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                print("❌ Failed to submit transcript:", error.localizedDescription)
            }
        }
    }
}
