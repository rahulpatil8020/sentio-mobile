import Foundation
import CoreLocation

@MainActor
final class OnboardingViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: - Inputs
    @Published var city = ""
    @Published var country = ""
    @Published var profession = ""
    @Published var selectedGoals: [String] = []
    @Published var customGoal = ""

    // MARK: - State
    @Published var isLoadingLocation = false
    @Published var locationDenied = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Config
    let maxGoalSelection = 5
    let minFieldLength = 2
    let maxFieldLength = 50
    let locationManager = CLLocationManager()

    let availableGoals = [
        "Improve focus", "Build healthy habits", "Reduce stress",
        "Increase productivity", "Enhance mindfulness", "Track emotions",
        "Organize tasks", "Better sleep", "Self-discipline"
    ]

    // MARK: - Validation
    var isFormValid: Bool {
        return cleaned(city).count >= minFieldLength ||
               cleaned(country).count >= minFieldLength ||
               cleaned(profession).count >= minFieldLength ||
               !selectedGoals.isEmpty ||
               cleaned(customGoal).count >= minFieldLength
    }

    private func cleaned(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let singleSpaced = trimmed.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return singleSpaced
    }

    func toggleGoal(_ goal: String) {
        if selectedGoals.contains(goal) {
            selectedGoals.removeAll { $0 == goal }
        } else if selectedGoals.count < maxGoalSelection {
            selectedGoals.append(goal)
        }
    }

    // MARK: - Location
    func requestLocation() {
        isLoadingLocation = true
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        } else {
            isLoadingLocation = false
            locationDenied = true
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                self.isLoadingLocation = false
                if let placemark = placemarks?.first {
                    self.city = placemark.locality ?? ""
                    self.country = placemark.country ?? ""
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoadingLocation = false
        locationDenied = true
    }

    // MARK: - Submit
    func submitOnboarding(onSuccess: @escaping () -> Void) async {
        city = cleaned(city)
        country = cleaned(country)
        profession = cleaned(profession)
        customGoal = cleaned(customGoal)

        if !customGoal.isEmpty {
            selectedGoals.append(customGoal)
        }

        guard city.count <= maxFieldLength,
              country.count <= maxFieldLength,
              profession.count <= maxFieldLength,
              selectedGoals.allSatisfy({ $0.count <= maxFieldLength }) else {
            errorMessage = "One or more fields exceed the character limit."
            return
        }

        isLoading = true
        errorMessage = nil

        let payload: [String: Any] = [
            "city": city,
            "country": country,
            "profession": profession,
            "goals": selectedGoals
        ]

        do {
            let body = try JSONSerialization.data(withJSONObject: payload)
            let response: OnboardResponse = try await APIClient.shared.request(
                endpoint: "/user/onboard",
                method: "POST",
                body: body,
                requiresAuth: true
            )

            // ✅ Set updated user in AppState
            AppState.shared.currentUser = response.data.user

            onSuccess()
        } catch let apiError as APIError {
            errorMessage = apiError.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    func skipOnboarding(onSuccess: @escaping () -> Void) async {
        isLoading = true
        errorMessage = nil

        do {
            let emptyPayload = try JSONSerialization.data(withJSONObject: [:])
            let response: OnboardResponse = try await APIClient.shared.request(
                endpoint: "/user/onboard",
                method: "POST",
                body: emptyPayload,
                requiresAuth: true
            )
            AppState.shared.currentUser = response.data.user
            onSuccess()
        } catch let apiError as APIError {
            errorMessage = apiError.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
