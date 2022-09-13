//
//  RingShape.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 13.09.2022.
//

import SwiftUI

extension Double {
    var radians: Double { self * Double.pi / 180 }
}

struct RingShape: Shape {
    static func percentToAngle(percent: Double, startAngle: Double) -> Double {
        (percent / 100 * 360) + startAngle
    }
    private var percent: Double
    private var startAngle: Double
    private let drawnClockwise: Bool
    
    var animatableData: Double {
        get { percent }
        set { percent = newValue }
    }
    
    init(percent: Double = 100, startAngle: Double = -90, drawnClockwise: Bool = false) {
        self.percent = percent
        self.startAngle = startAngle
        self.drawnClockwise = drawnClockwise
    }
    
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let radius = min(width, height) / 2
        let center = CGPoint(x: width / 2, y: height / 2)
        let endAngle = Angle(degrees: RingShape.percentToAngle(percent: percent, startAngle: startAngle))
        return Path { path in
            path.addArc(
                center: center,
                radius: radius,
                startAngle: Angle(degrees: startAngle),
                endAngle: endAngle,
                clockwise: drawnClockwise
            )
        }
    }
}
