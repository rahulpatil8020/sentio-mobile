//
//  OnboardingView.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/24/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var vm = OnboardingViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Location")) {
                    if vm.isLoadingLocation {
                        ProgressView("Fetching location...")
                    } else {
                        TextField("City", text: $vm.city) 
                        TextField("Country", text: $vm.country)
                        if vm.locationDenied {
                            Text("Location access denied. Please enter manually.")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        Button("Use My Current Location") {
                            vm.requestLocation()
                        }
                    }
                }

                Section(header: Text("About You")) {
                    TextField("Profession", text: $vm.profession)
                    TextField("Your Goal (e.g. build healthy habits)", text: $vm.goal)
                }

                Section {
                    Button("Continue") {
                        // Save optional info here or call API
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Skip for now") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
            .navigationTitle("Tell us about you")
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingView()
    }
}
