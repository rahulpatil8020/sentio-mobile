//
//  View+Placeholder.swift
//  Sentio-Mobile
//
//  Created by Rahul Patil on 8/23/25.
//

import SwiftUI

extension View {
    func placeholder(_ text: String,
                     when shouldShow: Bool,
                     color: Color = Color("TextSecondary")) -> some View {
        ZStack(alignment: .leading) {
            if shouldShow {
                Text(text)
                    .foregroundColor(color)
            }
            self
        }
    }
}

extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
