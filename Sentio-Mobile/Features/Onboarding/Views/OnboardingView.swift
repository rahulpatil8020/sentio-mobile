import SwiftUI

struct OnboardingView: View {
    @StateObject private var vm = OnboardingViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Surface").ignoresSafeArea() // 🌙 Themed background

                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {

                        // 🧠 Header
                        VStack(spacing: 8) {
                            Text("Tell us more about yourself")
                                .font(.largeTitle.bold())
                                .foregroundColor(Color("TextPrimary"))
                                .multilineTextAlignment(.center)

                            Text("This will help us personalize your experience.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)

                        // 🏙 Location Section
                        sectionCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Location")
                                    .font(.headline)
                                    .foregroundColor(Color("TextPrimary"))

                                InputField(
                                    placeholder: "City",
                                    text: $vm.city,
                                    systemImage: "building.2.fill",
                                    characterLimit: 50
                                )
                                .disabled(vm.isLoadingLocation) // disable while loading

                                InputField(
                                    placeholder: "Country",
                                    text: $vm.country,
                                    systemImage: "globe",
                                    characterLimit: 50
                                )
                                .disabled(vm.isLoadingLocation)

                                if vm.locationDenied {
                                    Text("Location access denied. Please enter manually.")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }

                                if !vm.isLoadingLocation {
                                    Button("Use My Current Location") {
                                        vm.requestLocation()
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(Color("Primary"))
                                }
                                // 👇 Loader shown under fields (instead of replacing them)
                                if vm.isLoadingLocation {
                                    ProgressView("Fetching location...")
                                        .font(.caption)
                                        .padding(.top, 4)
                                }
                            }
                        }

                        // 👔 Profession Section
                        sectionCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Profession")
                                    .font(.headline)
                                    .foregroundColor(Color("TextPrimary"))

                                InputField(
                                    placeholder: "e.g. Student, Developer",
                                    text: $vm.profession,
                                    systemImage: "person.text.rectangle",
                                    characterLimit: 50
                                )
                            }
                        }

                        // 🎯 Goals Section
                        sectionCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Your Goals")
                                    .font(.headline)
                                    .foregroundColor(Color("TextPrimary"))

                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(vm.availableGoals, id: \.self) { goal in
                                        Toggle(goal, isOn: Binding(
                                            get: { vm.selectedGoals.contains(goal) },
                                            set: { isSelected in vm.toggleGoal(goal) }
                                        ))
                                        .tint(Color("Primary"))
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
                        }

                        // ✅ Continue Button
                        Button(action: {
                            Task {
                                await vm.submitOnboarding {
                                    dismiss()
                                }
                            }
                        }) {
                            Text("Continue")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .foregroundColor(Color("Surface"))
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("Primary"))
                                )
                                .shadow(color: Color("Primary").opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .disabled(!vm.isFormValid || vm.isLoading)
                        .opacity(!vm.isFormValid || vm.isLoading ? 0.6 : 1.0)
                        .padding(.top)
                    }
                    .padding()
                }

                // 🔒 Loading Overlay
                if vm.isLoading {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    ProgressView("Saving...")
                        .padding()
                        .background(Color("Surface"))
                        .cornerRadius(12)
                        .shadow(color: Color("Primary").opacity(0.5), radius: 10)
                }
            }
            // 🔹 Top-right Skip button
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task {
                            await vm.skipOnboarding {
                                dismiss()
                            }
                        }
                    }) {
                        Text("Skip")
                            .underline()
                            .font(.subheadline)
                            .foregroundColor(Color("TextPrimary"))
                            .padding(10)
                    }
                }
            }
        }
    }

    // MARK: - Section Card Modifier
    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("Surface"))
            .cornerRadius(12)
    }
}

#Preview {
    OnboardingView()
        .environment(\.colorScheme, .dark)
}
