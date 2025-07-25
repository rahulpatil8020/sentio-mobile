//
//  DashboardGridCard.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/23/25.
//

import SwiftUI

struct DashboardGridCard: View {
    let title: String
    let color: Color
    let icon: String
    let content: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                Spacer()
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
            }

            Text(content)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(detail)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    DashboardGridCard(
        title: "Emotional State",
        color: .orange,
        icon: "face.smiling.fill",
        content: "Happy",
        detail: "Feeling good about today"
    )
    .padding()
    .previewLayout(.sizeThatFits)
}
