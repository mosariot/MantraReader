//
//  ProgressArc.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 19.09.2022.
//

import SwiftUI

struct ProgressArc: View {
    let progress: Double
    let colors: [Color]
    let thickness: Double
    let frame: CGSize
    
    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(
                progressAngularGradient(colors: colors),
                style: StrokeStyle(lineWidth: thickness, lineCap: .round))
            .rotationEffect(Angle(degrees: -90))
            .frame(
                width: min(frame.width, frame.height),
                height: min(frame.width, frame.height)
            )
    }
    
    private func progressAngularGradient(colors: [Color]) -> AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: colors),
            center: .center,
            startAngle: .degrees(0),
            endAngle: progress > 0.25 ? .degrees(360.0 * progress) : .degrees(90))
    }
}
