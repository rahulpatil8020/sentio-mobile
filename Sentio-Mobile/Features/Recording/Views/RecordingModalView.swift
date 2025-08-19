import SwiftUI

struct RecordingModalView: View {
    @StateObject private var viewModel = RecordingViewModel()
    @Binding var isPresented: Bool
    @State private var isPulsing = false
    @State private var showPermissionAlert = false
    @State private var showPrePrompt = false

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()

            VStack(spacing: 20) {
                Text(statusText)
                    .font(.headline)
                    .foregroundColor(Color("TextSecondary"))
                    .padding(.top, 30)

                transcriptSection

                Spacer()

                controlsSection
                    .padding(.bottom, 40)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.clear)
        .onChange(of: viewModel.state) { _, new in
            isPulsing = (new == .recording)
        }
        .alert("Microphone Access Required", isPresented: $showPermissionAlert) {
            Button("Go to Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable microphone access in Settings → Privacy → Speech Recognition & Microphone.")
                .foregroundColor(Color("TextPrimary"))
        }
        .overlay {
            if showPrePrompt { prePromptOverlay }
        }
    }

    // MARK: - Status
    private var statusText: String {
        switch viewModel.state {
        case .idle:      return "Ready"
        case .recording: return "Recording…"
        case .paused:    return "Paused"
//        case .finished:  return "Review & Submit"
        }
    }

    // MARK: - Transcript
    @ViewBuilder private var transcriptSection: some View {
//        if viewModel.state == .finished {
//            TextEditor(text: $viewModel.transcription)
//                .scrollContentBackground(.hidden)
//                .padding()
//                .frame(maxHeight: 300)
//                .background(Color("Surface"))
//                .foregroundColor(Color("TextPrimary"))
//                .cornerRadius(12)
//                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
//                .padding(.horizontal)
//        } else {
            ScrollView {
                Text(viewModel.transcription.isEmpty ? "Listening..." : viewModel.transcription)
                    .font(.body)
                    .foregroundColor(Color("TextPrimary"))
                    .padding()
            }
            .frame(maxHeight: 300)
//        }
    }

    // MARK: - Controls
    @ViewBuilder private var controlsSection: some View {
        switch viewModel.state {
        case .idle:
            // One big mic button
            centerRoundButton(icon: "mic.fill", bg: Color("Surface")) {
                let status = viewModel.currentPermissionStatus()
                if status == .notDetermined {
                    showPrePrompt = true
                } else {
                    viewModel.requestPermissionIfNeeded { granted in
                        granted ? viewModel.startRecording() : (showPermissionAlert = true)
                    }
                }
            }

        case .recording, .paused:
            // Three-button layout: Delete — Center(Pause/Play) — Submit
            HStack {
                // Left: delete (discard)
                smallIconButton(systemName: "trash", bg: Color("Surface")) {
                    discardCurrentTake()
                }

                Spacer()

                // Center: pause / play with pulse
                ZStack {
                    if viewModel.state == .recording {
                        Circle()
                            .fill(Color("Surface").opacity(0.25))
                            .frame(width: 140, height: 140)
                            .scaleEffect(isPulsing ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
                    }
                    centerRoundButton(
                        icon: viewModel.state == .recording ? "pause.fill" : "play.fill",
                        bg: Color("Surface")
                    ) {
                        if viewModel.state == .recording {
                            viewModel.pauseRecording()
                        } else {
                            viewModel.resumeRecording()
                        }
                    }
                }

                Spacer()

                // Right: submit
                smallIconButton(systemName: "paperplane.fill", bg: Color("Primary")) {
                    submitNowAndDismiss()
                }
            }
            .padding(.horizontal, 32)

//        case .finished:
//            // You can keep your existing finished buttons or reuse the 3-button bar (submit + delete)
//            VStack(spacing: 16) {
//                Button {
//                    submitNowAndDismiss()
//                } label: {
//                    Text("Submit Transcript")
//                        .font(.headline)
//                        .foregroundColor(Color("TextPrimary"))
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color("Primary"))
//                        .cornerRadius(12)
//                        .shadow(color: Color("Primary").opacity(0.4), radius: 5)
//                }
//                .padding(.horizontal, 40)
//
//                Button {
//                    isPresented = false
//                } label: {
//                    Text("Cancel")
//                        .font(.headline)
//                        .foregroundColor(Color("TextSecondary"))
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.white.opacity(0.05))
//                        .cornerRadius(12)
//                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
//                }
//                .padding(.horizontal, 40)
//            }
        }
    }

    // MARK: - Buttons
    private func centerRoundButton(icon: String, bg: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(Color("TextPrimary"))
                .padding(30)
                .background(
                    Circle()
                        .fill(bg)
                        .shadow(color: Color("SurfaceSecondary").opacity(0.5), radius: 5)
                )
        }
    }

    private func smallIconButton(systemName: String, bg: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("TextPrimary"))
                .padding(16)
                .background(
                    Circle()
                        .fill(bg)
                        .shadow(color: bg.opacity(0.4), radius: 6)
                )
        }
    }

    // MARK: - Actions
    private func submitNowAndDismiss() {
        // Finalize recording session if needed
        if viewModel.state == .recording || viewModel.state == .paused {
            viewModel.stopRecording()
        }

        // Start async submit (returns immediately) and dismiss the sheet
        viewModel.submitTranscript()
        isPresented = false
    }

    private func discardCurrentTake() {
        // Gracefully stop if needed and clear the transcript
        if viewModel.state == .recording || viewModel.state == .paused {
            viewModel.stopRecording()
        }
        // If your VM has a reset/cancel API, call it here instead:
        // viewModel.reset()
        viewModel.transcription = ""
        viewModel.state = .idle
    }

    // MARK: - Pre‑prompt Overlay
    @ViewBuilder private var prePromptOverlay: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea().onTapGesture { showPrePrompt = false }

            VStack(spacing: 24) {
                Text("We need your permission 🎙️")
                    .font(.title2).bold()
                    .foregroundColor(Color("TextPrimary"))

                Text("To transcribe your voice into text, the app requires access to your microphone and speech recognition.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("TextSecondary"))
                    .padding(.horizontal)

                Button("Continue") {
                    showPrePrompt = false
                    viewModel.requestPermissionIfNeeded { granted in
                        granted ? viewModel.startRecording() : (showPermissionAlert = true)
                    }
                }
                .font(.headline)
                .foregroundColor(Color("TextPrimary"))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("Primary"))
                .cornerRadius(12)
                .padding(.horizontal, 40)

                Button("Not Now", role: .cancel) { showPrePrompt = false }
                    .foregroundColor(Color("TextSecondary"))
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color("Surface")).shadow(color: .black.opacity(0.5), radius: 10))
            .padding(40)
        }
        .transition(.opacity)
        .animation(.easeInOut, value: showPrePrompt)
    }
}

#Preview {
    RecordingModalView(isPresented: .constant(true))
        .environment(\.colorScheme, .dark)
}
