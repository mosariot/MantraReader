//
//  RingCap.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 16.09.2022.
//

import SwiftUI

struct RingCap: Shape {
    var progress: Double
    let ringRadius: Double
    
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        guard progress > 0 else {
            return Path()
        }
        
        var path = Path()
        let progressAngle = Angle(degrees: (360.0 * progress) - 90.0)
        let tipRadius = rect.width / 2
        let center = CGPoint(
            x: ringRadius * cos(progressAngle.radians) + tipRadius,
            y: ringRadius * sin(progressAngle.radians) + tipRadius
        )
        let startAngle = progressAngle + .degrees(180)
        let endAngle = startAngle - .degrees(180)
        path.addArc(center: center, radius: tipRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.closeSubpath()
        return path
    }
}

struct RingClipShape: Shape {
    let radius: Double
    let thickness: Double
    
    func path(in rect: CGRect) -> Path {
        let outerRadius = radius + thickness / 2
        let innerRadius = radius - thickness / 2
        let center = CGPoint(x: rect.minX + rect.width / 2, y: rect.minY + rect.height / 2)
        var path = Path()
        path.addArc(center: center, radius: outerRadius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
        path.addArc(center: center, radius: innerRadius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
        return path
    }
}

extension Shape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: CGFloat) -> some View {
        self
            .stroke(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}
