//
//  RingColor.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 12.09.2022.
//

import SwiftUI

enum RingColor: String, Hashable, Codable {
    case red
    case yellow
    case green
    case dynamic
    
    var colors: [Color] {
        switch self {
        case .red: return [.progressRedStart, .progressRedEnd]
        case .yellow: return [.progressYellowStart, .progressYellowEnd]
        case .green: return [.progressGreenStart, .progressGreenEnd]
        case .dynamic: return [.progressRedStart]
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .red: return .progressRedStart.opacity(0.2)
        case .yellow: return .progressYellowStart.opacity(0.2)
        case .green: return .progressGreenStart.opacity(0.2)
        case .dynamic: return .gray.opacity(0.2)
        }
    }
}

extension Color {
    static let progressRedStart = Color(#colorLiteral(red: 0.882, green: 0.000, blue: 0.086, alpha: 1))
    static let progressRedEnd = Color(#colorLiteral(red: 1.000, green: 0.196, blue: 0.533, alpha: 1))
    static let progressYellowStart = Color(#colorLiteral(red: 0.89, green: 0.682, blue: 0.039, alpha: 1))
    static let progressYellowEnd = Color(#colorLiteral(red: 1, green: 0.815, blue: 0.169, alpha: 1))
    static let progressGreenStart = Color(#colorLiteral(red: 0.216, green: 0.863, blue: 0.000, alpha: 1))
    static let progressGreenEnd = Color(#colorLiteral(red: 0.569, green: 0.961, blue: 0, alpha: 1))
    
    static let firstProgressTier: [Color] = [.progressGreenStart, .progressGreenEnd]
    static let secondProgressTier: [Color] = [.progressYellowStart, .progressYellowEnd]
    static let thirdProgressTier: [Color] = [.progressRedStart, .progressRedEnd]
}
