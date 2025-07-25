import Foundation
import CoreLocation

@MainActor
final class OnboardingViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var city = ""
    @Published var country = ""
    @Published var profession = ""
    @Published var selectedGoals: [String] = []
    @Published var customGoal = ""

    @Published var isLoadingLocation = false
    @Published var locationDenied = false

    let maxGoalSelection = 5
    let locationManager = CLLocationManager()

    let availableGoals = [
        "Improve focus",
        "Build healthy habits",
        "Reduce stress",
        "Increase productivity",
        "Enhance mindfulness",
        "Track emotions",
        "Organize tasks",
        "Better sleep",
        "Self-discipline"
    ]

    func toggleGoal(_ goal: String) {
        if selectedGoals.contains(goal) {
            selectedGoals.removeAll { $0 == goal }
        } else if selectedGoals.count < maxGoalSelection {
            selectedGoals.append(goal)
        }
    }

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
}
