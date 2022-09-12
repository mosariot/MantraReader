//
//  PercentageRing.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 20.07.2022.
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

struct PercentageRing: View {
    private static let ShadowColor: Color = Color.black.opacity(0.3)
    private static let ShadowRadius: CGFloat = 4
    private static let ShadowOffsetMultiplier: CGFloat = ShadowRadius + 2
    
    private let ringWidth: CGFloat
    private let percent: Double
    private let backgroundColor: Color
    private let foregroundColors: [Color]
    private let startAngle: Double = -90
    private var gradientStartAngle: Double {
        percent >= 100 ? relativePercentageAngle - 360 : startAngle
    }
    private var absolutePercentageAngle: Double {
        RingShape.percentToAngle(percent: percent, startAngle: 0)
    }
    private var relativePercentageAngle: Double {
        absolutePercentageAngle + startAngle
    }
    private var firstGradientColor: Color {
        foregroundColors.first ?? .red
    }
    private var lastGradientColor: Color {
        foregroundColors.last ?? .red
    }
    private var ringGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: foregroundColors),
            center: .center,
            startAngle: Angle(degrees: gradientStartAngle),
            endAngle: Angle(degrees: percent > 25 ? relativePercentageAngle : 0)
        )
    }
    
    init(ringWidth: CGFloat, percent: Double, backgroundColor: Color, foregroundColors: [Color]) {
        self.ringWidth = ringWidth
        self.percent = percent
        self.backgroundColor = backgroundColor
        self.foregroundColors = foregroundColors
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RingShape()
                    .stroke(style: StrokeStyle(lineWidth: ringWidth))
                    .fill(backgroundColor)
                RingShape(percent: percent, startAngle: startAngle)
                    .stroke(style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                    .fill(ringGradient)
                if getShowShadow(frame: geometry.size) {
                    Circle()
                        .fill(lastGradientColor)
                        .frame(width: ringWidth, height: ringWidth, alignment: .center)
                        .offset(x: getEndCircleLocation(frame: geometry.size).x,
                                y: getEndCircleLocation(frame: geometry.size).y)
                        .shadow(color: PercentageRing.ShadowColor,
                                radius: PercentageRing.ShadowRadius,
                                x: getEndCircleShadowOffset().x,
                                y: getEndCircleShadowOffset().y)
                }
            }
        }
    }
    
    private func getEndCircleLocation(frame: CGSize) -> (x: CGFloat, y: CGFloat) {
        let angleOfEndInRadians: Double = relativePercentageAngle.radians
        let offsetRadius = min(frame.width, frame.height) / 2
        return (offsetRadius * CGFloat(cos(angleOfEndInRadians)), offsetRadius * CGFloat(sin(angleOfEndInRadians)))
    }
    
    private func getEndCircleShadowOffset() -> (x: CGFloat, y: CGFloat) {
        let angleForOffset = absolutePercentageAngle + (startAngle + 90)
        let angleForOffsetInRadians = angleForOffset.radians
        let relativeXOffset = cos(angleForOffsetInRadians)
        let relativeYOffset = sin(angleForOffsetInRadians)
        let xOffset = CGFloat(relativeXOffset) * PercentageRing.ShadowOffsetMultiplier
        let yOffset = CGFloat(relativeYOffset) * PercentageRing.ShadowOffsetMultiplier
        return (xOffset, yOffset)
    }
    
    private func getShowShadow(frame: CGSize) -> Bool {
        let circleRadius = min(frame.width, frame.height) / 2
        let remainingAngleInRadians = CGFloat((360 - absolutePercentageAngle).radians)
        if percent >= 100 || circleRadius * remainingAngleInRadians <= ringWidth {
            return true
        } else {
            return false
        }
    }
}
