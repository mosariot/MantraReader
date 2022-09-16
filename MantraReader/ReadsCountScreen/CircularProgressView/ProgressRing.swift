//
//  ProgressRing.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 16.09.2022.
//

import SwiftUI

struct ProgressRingOptions {
    public var radius: Double = 100
    public var thickness: Double = 30
    public var color: Color = .accentColor
    public var tipColor: Color? = nil
    public var backgroundColor: Color = .init(.systemGray6)
    public var tipShadowColor: Color = .black.opacity(0.1)
    public var outlineColor: Color = .init(.systemGray4)
    public var outlineThickness: Double = 1
    
    public init() { }
}

struct ProgressRing: View {
    @EnvironmentObject private var settings: Settings
    
    let progress: Double
    let options: ProgressRingOptions
    
    init(progress: Double, options: ProgressRingOptions) {
        self.progress = progress
        self.options = options
    }
    
    private var effectiveTipColor: Color {
        options.tipColor ?? options.color
    }
    
    private func ProgressAngularGradient(colors: [Color]) -> AngularGradient{
        AngularGradient(
            gradient: Gradient(colors: colors),
            center: .center,
            startAngle: .degrees(0),
            endAngle: progress > 0.25 ? .degrees(360.0 * progress) : .degrees(90))
    }
    
    public var body: some View {
        ZStack {
            if options.backgroundColor != .clear {
                Circle()
                    .stroke(options.backgroundColor, lineWidth: options.thickness)
                    .frame(width: options.radius * 2.0)
            }
            if options.outlineColor != .clear {
                Circle()
                    .stroke(options.outlineColor, lineWidth: options.outlineThickness)
                    .frame(width:(options.radius * 2.0) + options.thickness - options.outlineThickness)
                Circle()
                    .stroke(options.outlineColor, lineWidth: options.outlineThickness)
                    .frame(width:(options.radius * 2.0) - options.thickness + options.outlineThickness)
            }
            Circle()
                .trim(from: 0, to: self.progress)
                .stroke(
                    ProgressAngularGradient(colors: [.darkGreen, .brightGreen]),
                    style: StrokeStyle(lineWidth: options.thickness, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .frame(width: options.radius * 2.0)
                .opacity(progress < 0.5 ? 1 : 0)
                .animation(.easeOut, value: progress)
            Circle()
                .trim(from: 0, to: self.progress)
                .stroke(
                    ProgressAngularGradient(colors: [.darkBlue, .brightBlue]),
                    style: StrokeStyle(lineWidth: options.thickness, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .frame(width: options.radius * 2.0)
                .opacity(progress >= 0.5 && progress < 1.0 ? 1 : 0)
                .animation(.easeOut, value: progress)
            Circle()
                .trim(from: 0, to: self.progress)
                .stroke(
                    ProgressAngularGradient(colors: [.darkRed, .brightRed]),
                    style: StrokeStyle(lineWidth: options.thickness, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .frame(width: options.radius * 2.0)
                .opacity(progress >= 1.0 ? 1 : 0)
                .animation(.easeOut, value: progress)
            RingCap(progress: progress,
                    ringRadius: options.radius)
            .fill(progress < 1.0 ? Color.brightBlue : Color.brightRed, strokeBorder: progress < 1.0 ? Color.brightBlue : Color.brightRed, lineWidth: 1) // hide seam
            .frame(width:options.thickness, height:options.thickness)
            .shadow(color: options.tipShadowColor,
                    radius: 2.5,
                    x: ringTipShadowOffset.x,
                    y: ringTipShadowOffset.y
            )
            .clipShape(
                RingClipShape(radius: options.radius, thickness: options.thickness)
            )
            .opacity(tipOpacity)
            .animation(.easeOut, value: progress)
        }
        .aspectRatio(1, contentMode: .fill)
        .frame(width: size, height: size)
    }
    
    private var size: Double {
        return options.radius * 2 + options.thickness
    }
    
    private var tipOpacity: Double {
        if progress < 0.95 {
            return 0
        } else {
            return 1
        }
    }
    
    private var ringTipShadowOffset: CGPoint {
        let ringTipPosition = tipPosition(progress: progress, radius: options.radius)
        let shadowPosition = tipPosition(progress: progress + 0.0075, radius: options.radius)
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
