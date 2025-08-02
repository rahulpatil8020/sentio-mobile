//
//  MainView.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/29/25.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab: String = "home"
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case "home":
                    HomeView()
                case "notifications":
                    NotificationsView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // 🔹 Background should always come from semantic color
            .background(Color("Background").ignoresSafeArea())
            
            VStack {
                Spacer()
                CustomNavBar(selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    MainView()
        .environment(\.colorScheme, .dark)   // 👈 Preview dark mode
}
