//
//  RingColor.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 12.09.2022.
//

import SwiftUI

enum RingColor: String, Hashable {
    case red
    case green
    case blue
    case dynamic
    
    var colors: [Color] {
        switch self {
        case .red: return [.progressRedStart, .progressRedEnd]
        case .green: return [.progressGreenStart, .progressGreenEnd]
        case .blue: return [.progressBlueStart, .progressBlueEnd]
        default: return [.red]
        }
    }
}

extension Color {
    static let progressRedStart = Color(#colorLiteral(red: 0.882, green: 0.000, blue: 0.086, alpha: 1))
    static let progressRedEnd = Color(#colorLiteral(red: 1.000, green: 0.196, blue: 0.533, alpha: 1))
    static let progressGreenStart = Color(#colorLiteral(red: 0.216, green: 0.863, blue: 0.000, alpha: 1))
    static let progressGreenEnd = Color(#colorLiteral(red: 0.714, green: 1.000, blue: 0.000, alpha: 1))
    static let progressBlueStart = Color(#colorLiteral(red: 0.000, green: 0.733, blue: 0.890, alpha: 1))
    static let progressBlueEnd = Color(#colorLiteral(red: 0.000, green: 0.984, blue: 0.816, alpha: 1))
}
