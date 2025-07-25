//
//  DashboardCardView.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/22/25.
//

import SwiftUI

struct DashboardCardView<Content: View>: View {
    let title: String
    let color: Color
    let icon: String
    let content: Content

    init(title: String, color: Color, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.color = color
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.title2.bold())
                    .foregroundColor(color)
                Spacer()
            }
            .padding(.bottom, 5)
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.primary.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}


#Preview("Habits Card") {
    DashboardCardView(
        title: "Habits",
        color: .blue,
        icon: "flame.fill"
    ) {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<3) { index in
                VStack(alignment: .leading) {
                    Text("Habit \(index + 1)")
                        .font(.headline)
                    Text("This is a description for habit \(index + 1).")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Divider()
                }
            }
        }
    }
}

#Preview("Todos Card") {
    DashboardCardView(
        title: "Todos",
        color: .green,
        icon: "checkmark.circle.fill"
    ) {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<3) { index in
                HStack {
                    Text("Todo \(index + 1)")
                    Spacer()
                    Image(systemName: index % 2 == 0 ? "checkmark.seal.fill" : "circle")
                        .foregroundColor(index % 2 == 0 ? .green : .gray)
                }
                Divider()
            }
        }
    }
}

#Preview("Reminders Card") {
    DashboardCardView(
        title: "Reminders",
        color: .purple,
        icon: "bell.fill"
    ) {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<2) { index in
                VStack(alignment: .leading) {
                    Text("Reminder \(index + 1)")
                        .font(.body)
                    Text("Remind at: 2025-07-30 09:00 AM")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Divider()
                }
            }
        }
    }
}
