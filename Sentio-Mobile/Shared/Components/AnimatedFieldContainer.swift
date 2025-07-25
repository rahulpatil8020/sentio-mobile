//
//  AnimatedFieldContainer.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 7/25/25.
//

import SwiftUI

struct AnimatedFieldContainer<Content: View>: View {
    let delay: Double
    let content: Content
    @State private var appear = false

    init(delay: Double, @ViewBuilder content: () -> Content) {
        self.delay = delay
        self.content = content()
    }

    var body: some View {
        content
            .opacity(appear ? 1 : 0)
            .offset(x: appear ? 0 : -50) // Slide in from left
            .transition(.asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            ))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        appear = true
                    }
                }
            }
            .onDisappear {
                withAnimation(.easeIn(duration: 0.3)) {
                    appear = false
                }
            }
    }
}
