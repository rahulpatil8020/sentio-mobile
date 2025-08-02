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
    let minFieldLength = 2
    let maxFieldLength = 50
    private let locationManager = CLLocationManager()

    let availableGoals = [
        "Improve mental health",
        "Build physical fitness",
        "Advance in career/education",
        "Strengthen relationships",
        "Enhance spirituality/mindfulness",
        "Achieve financial stability",
        "Personal growth & learning",
        "Enjoy hobbies & leisure"
    ]

    // MARK: - Init
    override init() {
        super.init()
        locationManager.delegate = self
    }

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
        } else {
            selectedGoals.append(goal)
        }
    }

    // MARK: - Location
    func requestLocation() {
        isLoadingLocation = true
        locationDenied = false

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            isLoadingLocation = false
            locationDenied = true
        @unknown default:
            isLoadingLocation = false
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            Task { @MainActor in
                self.locationDenied = false
                manager.requestLocation()
            }
        case .denied, .restricted:
            Task { @MainActor in
                self.isLoadingLocation = false
                self.locationDenied = true
            }
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            Task { @MainActor in
                self.isLoadingLocation = false
                if let placemark = placemarks?.first {
                    self.city = placemark.locality ?? ""
                    self.country = placemark.country ?? ""
                }
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.isLoadingLocation = false
            self.locationDenied = true
        }
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
