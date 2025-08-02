//
//  ElevationModifies.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 8/2/25.
//

import SwiftUI

enum Elevation {
    case low
    case medium
    case high
    
    var shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        switch self {
        case .low:
            return (.black.opacity(0.15), 4, 0, 2)   // subtle
        case .medium:
            return (.black.opacity(0.25), 8, 0, 4)   // nav bars, modals
        case .high:
            return (.black.opacity(0.35), 12, 0, 6)  // floating buttons
        }
    }
}

struct ElevationModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let level: Elevation
    
    func body(content: Content) -> some View {
        let (color, radius, x, y) = level.shadow
        content.shadow(
            color: colorScheme == .dark ? color.opacity(1.2) : color,
            radius: radius,
            x: x,
            y: y
        )
    }
}

extension View {
    func elevation(_ level: Elevation) -> some View {
        self.modifier(ElevationModifier(level: level))
    }
}
