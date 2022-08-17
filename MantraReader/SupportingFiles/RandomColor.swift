//
//  RandomColor.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 14.07.2022.
//

import SwiftUI

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
