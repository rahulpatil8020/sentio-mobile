//
//  Badges.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 8/23/25.
//

import SwiftUI

struct StreakBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct FrequencyBadge: View {
    let text: String

    var body: some View {
        let color: Color = {
            switch text.lowercased() {
            case "daily": return .teal
            case "weekly": return .orange
            case "monthly": return .purple
            default: return .gray
            }
        }()
        return Text(text.capitalized)
            .font(.caption2.weight(.bold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
