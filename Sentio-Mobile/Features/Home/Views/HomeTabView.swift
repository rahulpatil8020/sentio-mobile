//
//  HomeTabView.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/23/25.
//

import SwiftUI

struct HomeTabView: View {
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        TabView {
            DashboardTabView(vm: vm)
                .tabItem {
                    Label("Dashboard", systemImage: "rectangle.grid.2x2.fill")
                }

            ProfileTabView(vm: vm)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }

            NotificationsTabView()
                .tabItem {
                    Label("Notifications", systemImage: "bell.fill")
                }
        }
        .task {
            await vm.fetchData()
        }
    }
}

#Preview {
    HomeTabView()
}
