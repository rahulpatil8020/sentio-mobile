import SwiftUI

struct OnboardingView: View {
    @StateObject private var vm = OnboardingViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // 🏙 Location Section
                        GroupBox(label: Label("Location", systemImage: "location.fill")) {
                            VStack(alignment: .leading, spacing: 10) {
                                if vm.isLoadingLocation {
                                    ProgressView("Fetching location...")
                                } else {
                                    InputField(
                                        placeholder: "City",
                                        text: $vm.city,
                                        systemImage: "building.2.fill",
                                        characterLimit: 50
                                    )
                                    .onChange(of: vm.city) {
                                        if vm.city.count > 50 {
                                            vm.city = String(vm.city.prefix(50))
                                        }
                                    }

                                    InputField(
                                        placeholder: "Country",
                                        text: $vm.country,
                                        systemImage: "globe",
                                        characterLimit: 50
                                    )
                                    .onChange(of: vm.country) {
                                        if vm.country.count > 50 {
                                            vm.country = String(vm.country.prefix(50))
                                        }
                                    }

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
                            .padding(.top, 5)
                        }

                        // 🧑‍💼 Profession Section
                        GroupBox(label: Label("Profession", systemImage: "briefcase.fill")) {
                            InputField(
                                placeholder: "e.g. Student, Developer",
                                text: $vm.profession,
                                systemImage: "person.text.rectangle",
                                characterLimit: 50
                            )
                            .onChange(of: vm.profession) {
                                if vm.profession.count > 50 {
                                    vm.profession = String(vm.profession.prefix(50))
                                }
                            }
                        }

                        // 🎯 Goals Section
                        GroupBox(label: Label("Your Goals", systemImage: "target")) {
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
                                .onChange(of: vm.customGoal) {
                                    if vm.customGoal.count > 50 {
                                        vm.customGoal = String(vm.customGoal.prefix(50))
                                    }
                                }
                            }
                            .padding(.top, 5)
                        }

                        // ✅ Action Buttons
                        VStack(spacing: 12) {
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
                                dismiss()
                            }
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                }

                // 🔒 Loading Overlay
                if vm.isLoading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView("Saving...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
            }
            .navigationTitle("Tell us about you")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    OnboardingView()
}

    #Preview {
        NavigationStack {
            OnboardingView()
        }
    }
