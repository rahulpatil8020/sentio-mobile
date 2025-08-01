import Foundation
import Speech
import AVFoundation
import Combine
import SwiftUI

class SpeechService: NSObject, ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    @Published var transcription: String = ""
    @Published var isAuthorized: Bool = false
    @Published var showPermissionAlert: Bool = false  // 🚨 custom alert flag
    
    private var isPaused: Bool = false
    
    override init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    // 🔹 Check current permission state
    private func checkAuthorizationStatus() {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            isAuthorized = false
        case .denied, .restricted:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }
    
    // 🔹 Ask for permission only when needed
    func requestPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
        let status = SFSpeechRecognizer.authorizationStatus()
        switch status {
        case .authorized:
            isAuthorized = true
            completion(true)
            
        case .notDetermined:
            // System prompt
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    self.isAuthorized = (status == .authorized)
                    completion(self.isAuthorized)
                }
            }
            
        case .denied, .restricted:
            // 🚨 Already denied → show your own alert
            DispatchQueue.main.async {
                self.showPermissionAlert = true
                completion(false)
            }
            
        @unknown default:
            completion(false)
        }
    }
    
    // 🔹 Start or Resume recording
    func startRecording(reset: Bool = true) throws {
        if audioEngine.isRunning { stopRecording() }
        
        if reset { transcription = "" }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcription = result.bestTranscription.formattedString
                }
            }
            if error != nil || (result?.isFinal ?? false) {
                self.stopRecording()
            }
        }
        
        isPaused = false
    }
    
    // 🔹 Pause recording
    func pauseRecording() {
        guard audioEngine.isRunning else { return }
        audioEngine.pause()
        recognitionRequest?.endAudio()
        isPaused = true
    }
    
    // 🔹 Resume recording
    func resumeRecording() throws {
        guard isPaused else { return }
        try startRecording(reset: false)
    }
    
    // 🔹 Stop completely
    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isPaused = false
    }
}
