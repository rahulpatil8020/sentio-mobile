import SwiftUI

struct OnboardingView: View {
    @StateObject private var vm = OnboardingViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {

                        // 🧠 Header
                        VStack(spacing: 8) {
                            Text("Tell us more about yourself")
                                .font(.largeTitle.bold())
                                .multilineTextAlignment(.center)

                            Text("This will help us personalize your experience.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)

                        // 🏙 Location Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📍 Location")
                                .font(.headline)

                            if vm.isLoadingLocation {
                                ProgressView("Fetching location...")
                            } else {
                                InputField(
                                    placeholder: "City",
                                    text: $vm.city,
                                    systemImage: "building.2.fill",
                                    characterLimit: 50
                                )

                                InputField(
                                    placeholder: "Country",
                                    text: $vm.country,
                                    systemImage: "globe",
                                    characterLimit: 50
                                )

                                if vm.locationDenied {
                                    Text("Location access denied. Please enter manually.")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }

                                Button("Use My Current Location") {
                                    vm.requestLocation()
                                }
                                .font(.subheadline)
                            }
                        }
                        .padding()
                        .cornerRadius(12)

                        // 👔 Profession Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("💼 Profession")
                                .font(.headline)

                            InputField(
                                placeholder: "e.g. Student, Developer",
                                text: $vm.profession,
                                systemImage: "person.text.rectangle",
                                characterLimit: 50
                            )
                        }
                        .padding()
                        .cornerRadius(12)

                        // 🎯 Goals Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🎯 Your Goals")
                                .font(.headline)

                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(vm.availableGoals, id: \.self) { goal in
                                    Toggle(goal, isOn: Binding(
                                        get: { vm.selectedGoals.contains(goal) },
                                        set: { isSelected in vm.toggleGoal(goal) }
                                    ))
                                    .disabled(!vm.selectedGoals.contains(goal) && vm.selectedGoals.count >= vm.maxGoalSelection)
                                }

                                InputField(
                                    placeholder: "Add custom goal (optional)",
                                    text: $vm.customGoal,
                                    systemImage: "plus.circle",
                                    characterLimit: 50
                                )
                                .padding(.top, 15)
                            }
                        }
                        .padding()
                        .cornerRadius(12)

                        // ✅ Action Buttons
                        VStack(spacing: 16) {
                            Button("Continue") {
                                Task {
                                    await vm.submitOnboarding {
                                        dismiss()
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity)
                            .disabled(!vm.isFormValid || vm.isLoading)

                            Button("Skip for now") {
                                Task {
                                    await vm.skipOnboarding {
                                        dismiss()
                                    }
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        }
                        .padding(.top)
                    }
                    .padding()
                }

                // 🔒 Loading Overlay
                if vm.isLoading {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView("Saving...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}
