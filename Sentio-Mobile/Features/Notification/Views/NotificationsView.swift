//
//  NotificationsTabView.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/23/25.
//

import SwiftUI

struct NotificationsView: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<10, id: \.self) { index in
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                        Text("Notification \(index + 1)")
                    }
                }
            }
            .navigationTitle("Notifications")
        }
    }
}

#Preview {
    NotificationsView()
}
