//
//  HomeView.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/22/25.
//

import SwiftUI

struct HomeView: View {
    var unreadCount: Int = 0
    
    var body: some View {
        HStack{
            ZStack {
                // Background circle
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                
                // Profile symbol
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
            }
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 3) // border
            )
        }
    }
}

#Preview {
    HomeView()
}
