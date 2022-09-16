//
//  ProgressRing.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 16.09.2022.
//

import SwiftUI

struct ProgressRingOptions {
    var thickness: Double = 25
    var tipShadowColor: Color = .black.opacity(0.25)
    var outlineColor: Color = .clear
    var outlineThickness: Double = 1
    
    public init() { }
}

struct ProgressRing: View {
    @EnvironmentObject private var settings: Settings
    
    let progress: Double
    let radius: Double
    var thickness: Double = 25
    var tipShadowColor: Color = .black.opacity(0.25)
    var outlineColor: Color = .clear
    var outlineThickness: Double = 1
    
    private var backgroundColor: Color { settings.ringColor.backgroundColor }
    private var foregroundColors: [Color] { settings.ringColor.colors }
    
    private var firstGradientColor: Color {
        foregroundColors.first ?? .accentColor
    }
    
    private var lastGradientColor: Color {
        switch settings.ringColor {
        case .red, .yellow, .green: return foregroundColors.last ?? .accentColor
        case .dynamic:
            if progress < 0.5 {
                return .firstProgressTier.last ?? .progressGreenStart
            } else if progress >= 0.5 && progress < 1.0 {
                return .secondProgressTier.last ?? .progressYellowStart
            } else if progress >= 1.0 {
                return .thirdProgressTier.last ?? .progressRedStart
            } else {
                return .accentColor
            }
        }
    }
    
    private func progressAngularGradient(colors: [Color]) -> AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: colors),
            center: .center,
            startAngle: .degrees(0),
            endAngle: progress > 0.25 ? .degrees(360.0 * progress) : .degrees(90))
    }
    
    public var body: some View {
        ZStack {
            if backgroundColor != .clear {
                Circle()
                    .stroke(backgroundColor, lineWidth: thickness)
                    .frame(width: radius * 2.0)
            }
            if outlineColor != .clear {
                Circle()
                    .stroke(outlineColor, lineWidth: outlineThickness)
                    .frame(width:(radius * 2.0) + thickness - outlineThickness)
                Circle()
                    .stroke(outlineColor, lineWidth: outlineThickness)
                    .frame(width:(radius * 2.0) - thickness + outlineThickness)
            }
            switch settings.ringColor {
            case .red, .yellow, .green:
                Circle()
                    .trim(from: 0, to: self.progress)
                    .stroke(
                        progressAngularGradient(colors: foregroundColors),
                        style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                    .rotationEffect(Angle(degrees: -90))
                    .frame(width: radius * 2.0)
                RingCap(progress: progress,
                        ringRadius: radius)
                .fill(lastGradientColor, strokeBorder: lastGradientColor, lineWidth: 1)
                .frame(width: thickness, height: thickness)
                .shadow(color: tipShadowColor,
                        radius: 2.5,
                        x: ringTipShadowOffset.x,
                        y: ringTipShadowOffset.y
                )
                .clipShape(
                    RingClipShape(radius: radius, thickness: thickness)
                )
                .opacity(tipOpacity)
            case .dynamic:
                Circle()
                    .trim(from: 0, to: self.progress)
                    .stroke(
                        progressAngularGradient(colors: [.progressGreenStart, .progressGreenEnd]),
                        style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                    .rotationEffect(Angle(degrees: -90))
                    .frame(width: radius * 2.0)
                    .opacity(progress < 0.5 ? 1 : 0)
                Circle()
                    .trim(from: 0, to: self.progress)
                    .stroke(
                        progressAngularGradient(colors: [.progressYellowStart, .progressYellowEnd]),
                        style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                    .rotationEffect(Angle(degrees: -90))
                    .frame(width: radius * 2.0)
                    .opacity(progress >= 0.5 && progress < 1.0 ? 1 : 0)
                Circle()
                    .trim(from: 0, to: self.progress)
                    .stroke(
                        progressAngularGradient(colors: [.progressRedStart, .progressRedEnd]),
                        style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                    .rotationEffect(Angle(degrees: -90))
                    .frame(width: radius * 2.0)
                    .opacity(progress >= 1.0 ? 1 : 0)
                RingCap(progress: progress,
                        ringRadius: radius)
                .fill(progress < 1.0 ? Color.progressYellowEnd : Color.progressRedEnd,
                      strokeBorder: progress < 1.0 ? Color.progressYellowEnd : Color.progressRedEnd,
                      lineWidth: 1)
                .frame(width: thickness, height: thickness)
                .shadow(color: tipShadowColor,
                        radius: 2.5,
                        x: ringTipShadowOffset.x,
                        y: ringTipShadowOffset.y
                )
                .clipShape(
                    RingClipShape(radius: radius, thickness: thickness)
                )
                .opacity(tipOpacity)
            }
        }
        .aspectRatio(1, contentMode: .fill)
        .frame(width: size, height: size)
    }
    
    private var size: Double {
        return radius * 2 + thickness
    }
    
    private var tipOpacity: Double {
        if progress < 0.95 {
            return 0
        } else {
            return 1
        }
    }
    
    private var ringTipShadowOffset: CGPoint {
        let ringTipPosition = tipPosition(progress: progress, radius: radius)
        let shadowPosition = tipPosition(progress: progress + 0.0075, radius: radius)
        return CGPoint(x: shadowPosition.x - ringTipPosition.x,
                       y: shadowPosition.y - ringTipPosition.y)
    }
    
    private func tipPosition(progress: Double, radius: Double) -> CGPoint {
        let progressAngle = Angle(degrees: (360.0 * progress) - 90.0)
        return CGPoint(
            x: radius * cos(progressAngle.radians),
            y: radius * sin(progressAngle.radians))
    }
}

extension Shape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: CGFloat = 1) -> some View {
        self
            .stroke(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
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

let darken = 0.7
let brightR: SIMD3<Double> = [1, 0.2, 0.2]
let darkR = brightR * darken
let brightG: SIMD3<Double> = [0, 1, 0]
let darkG = brightG * darken
let brightB: SIMD3<Double> = [0, 0.7, 1]
let darkB = brightB * darken

extension Color {
    static let brightRed = Color(brightR)
    static let darkRed = Color(darkR)
    static let brightGreen = Color(brightG)
    static let darkGreen = Color(darkG)
    static let brightBlue = Color(brightB)
    static let darkBlue = Color(darkB)
}

extension Color {
    init(_ simd: SIMD3<Double>) {
        self.init(red: simd.x, green: simd.y, blue: simd.z)
    }
}
