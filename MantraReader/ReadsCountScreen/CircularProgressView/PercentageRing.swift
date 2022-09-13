//
//  PercentageRing.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 20.07.2022.
//

import SwiftUI

struct PercentageRing: View {
    @AppStorage("ringColor") private var ringColor: RingColor = .red
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
        switch ringColor {
        case .red, .yellow, .green: return foregroundColors.last ?? .red
        case .dynamic:
            if percent < 50 {
                return foregroundColors[5]
            } else if percent >= 50 && percent < 100 {
                return foregroundColors[3]
            } else if percent >= 100 {
                return foregroundColors[1]
            } else {
                return .red
            }
        }
    }
    private func ringGradient(colors: [Color]) -> AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: colors),
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
                switch ringColor {
                case .red, .yellow, .green:
                    RingShape(percent: percent, startAngle: startAngle)
                        .stroke(style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                        .fill(ringGradient(colors: foregroundColors))
                case .dynamic:
                        RingShape(percent: percent, startAngle: startAngle)
                            .stroke(style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                            .fill(ringGradient(colors: [foregroundColors[4], foregroundColors[5]]))
                            .opacity(percent < 50 ? 1 : 0)
                        RingShape(percent: percent, startAngle: startAngle)
                            .stroke(style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                            .fill(ringGradient(colors: [foregroundColors[2], foregroundColors[3]]))
                            .opacity(percent >= 50 && percent < 100 ? 1 : 0)
                        RingShape(percent: percent, startAngle: startAngle)
                            .stroke(style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                            .fill(ringGradient(colors: [foregroundColors[0], foregroundColors[1]]))
                            .opacity(percent >= 100 ? 1 : 0)
                }
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
