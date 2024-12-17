//
//  View + Extension.swift
//  Crazy
//
//  Created by D K on 14.12.2024.
//

import SwiftUI


extension Color {
    static let darkPurple = Color(#colorLiteral(red: 0.03529411765, green: 0, blue: 0.1803921569, alpha: 1))
    static let semiPurple = Color(#colorLiteral(red: 0.1960784314, green: 0.01960784314, blue: 0.337254902, alpha: 1))
}

extension View {
    func size() -> CGSize {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        return window.screen.bounds.size
    }
}
