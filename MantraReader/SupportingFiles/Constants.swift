//
//  Constants.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 21.06.2022.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum Constants {
    static let defaultImage = "DefaultImage"
    static let rowHeight = 55
    static let initialReadsGoal = 100_000
    static let animationTime: Double = 1.0
    static let progressStartColor = "progressStart"
    static let progressEndColor = "progressEnd"
#if os(iOS)
    static let accentColor = UIColor(named: "AccentColor")
#elseif os(macOS)
    static let accentColor = NSColor(named: "AccentColor")
#endif
}

