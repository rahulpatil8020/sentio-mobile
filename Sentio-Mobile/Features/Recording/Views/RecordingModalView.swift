import SwiftUI

struct RecordingModalView: View {
    @StateObject private var viewModel = RecordingViewModel()
    @Binding var isPresented: Bool
    @State private var isPulsing = false
    @State private var showPermissionAlert = false   // 🚨 For denied state
    @State private var showPrePrompt = false         // 🚨 Our new custom modal
    
    var body: some View {
        ZStack {
            Color("background2Color").ignoresSafeArea()
            
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 40, height: 6)
                    .padding(.top, 20)

                Text(statusText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 10)

                transcriptSection

                Spacer()

                controlsSection
                    .padding(.bottom, 40)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.clear)
        .onChange(of: viewModel.state) {
            isPulsing = (viewModel.state == .recording)
        }
        .alert("Microphone Access Required",
               isPresented: $showPermissionAlert) {
            Button("Go to Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable microphone access in Settings → Privacy → Speech Recognition & Microphone.")
        }
        
        // 🔹 Custom Permission Modal Overlay
        .overlay {
            if showPrePrompt {
                ZStack {
                    // Dimmed black background
                    Color.black.opacity(0.9)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showPrePrompt = false
                        }

                    VStack(spacing: 24) {
                        Text("We need your permission 🎙️")
                            .font(.title2).bold()
                            .foregroundColor(.white)

                        Text("To transcribe your voice into text, the app requires access to your microphone and speech recognition.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal)

                        Button("Continue") {
                            showPrePrompt = false
                            viewModel.requestPermissionIfNeeded { granted in
                                if granted {
                                    viewModel.startRecording()
                                } else {
                                    showPermissionAlert = true
                                }
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)

                        Button("Not Now", role: .cancel) {
                            showPrePrompt = false
                        }
                        .foregroundColor(.gray)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("background2Color"))
                            .shadow(color: .black.opacity(0.5), radius: 10)
                    )
                    .padding(40)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: showPrePrompt)
            }
        }
    }
    
    // MARK: - Status Label
    private var statusText: String {
        switch viewModel.state {
        case .idle: return "Ready"
        case .recording: return "Recording…"
        case .paused: return "Paused"
        case .finished: return "Review & Submit"
        }
    }
    
    // MARK: - Transcript Section
    @ViewBuilder
    private var transcriptSection: some View {
        if viewModel.state == .finished {
            TextEditor(text: $viewModel.transcription)
                .scrollContentBackground(.hidden)
                .padding()
                .frame(maxHeight: 300)
                .background(Color("background2Color"))
                .foregroundColor(.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
        } else {
            ScrollView {
                Text(viewModel.transcription.isEmpty ? "Listening..." : viewModel.transcription)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
            }
            .frame(maxHeight: 300)
        }
    }
    
    // MARK: - Controls Section
    @ViewBuilder
    private var controlsSection: some View {
        switch viewModel.state {
        case .idle:
            recordButton(icon: "mic.fill", color: .green) {
                let status = viewModel.currentPermissionStatus()
                if status == .notDetermined {
                    showPrePrompt = true   // 🚨 open custom modal
                } else {
                    viewModel.requestPermissionIfNeeded { granted in
                        if granted {
                            viewModel.startRecording()
                        } else {
                            showPermissionAlert = true
                        }
                    }
                }
            }
            
        case .recording:
            recordButton(icon: "pause.fill", color: .yellow) {
                viewModel.pauseRecording()
            }
            
        case .paused:
            ZStack {
                recordButton(icon: "play.fill", color: .green) {
                    viewModel.resumeRecording()
                }

                stopButton
                    .offset(x: 100)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
        case .finished:
            finishedButtons
        }
    }
    
    // MARK: - Record Button with Pulse
    private func recordButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        ZStack {
            if viewModel.state == .recording {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 140, height: 140)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                        value: isPulsing
                    )
            }

            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .padding(40)
                    .background(
                        Circle()
                            .fill(color)
                            .shadow(color: .white.opacity(0.8), radius: 15)
                    )
            }
        }
    }
    
    // MARK: - Stop Button
    private var stopButton: some View {
        Button {
            viewModel.stopRecording()
        } label: {
            Image(systemName: "stop.fill")
                .font(.system(size: 22))
                .foregroundColor(.white)
                .padding(18)
                .background(
                    Circle()
                        .fill(Color.red)
                        .shadow(color: .white.opacity(0.6), radius: 8)
                )
        }
    }
    
    // MARK: - Finished Buttons
    private var finishedButtons: some View {
        VStack(spacing: 16) {
            Button {
                viewModel.submitTranscript {
                    isPresented = false
                }
            } label: {
                Text("Submit Transcript")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .white.opacity(0.4), radius: 5)
            }
            .padding(.horizontal, 40)
            
            Button {
                isPresented = false
            } label: {
                Text("Cancel")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 40)
        }
    }
}
