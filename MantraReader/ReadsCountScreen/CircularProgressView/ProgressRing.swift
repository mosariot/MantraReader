//
//  ProgressRing.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 16.09.2022.
//

import SwiftUI

struct ProgressRing: View {
    @EnvironmentObject private var settings: Settings
    
    let progress: Double
    let thickness: Double
    
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
        GeometryReader { geo in
            ZStack {
                Circle()
                    .stroke(backgroundColor, lineWidth: thickness)
                    .frame(
                        width: min(geo.size.width, geo.size.height),
                        height: min(geo.size.width, geo.size.height)
                    )
                switch settings.ringColor {
                case .red, .yellow, .green:
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            progressAngularGradient(colors: foregroundColors),
                            style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                        .rotationEffect(Angle(degrees: -90))
                        .frame(
                            width: min(geo.size.width, geo.size.height),
                            height: min(geo.size.width, geo.size.height)
                        )
                    RingCap(progress: progress,
                            ringRadius: min(geo.size.width, geo.size.height) / 2)
                    .fill(lastGradientColor, strokeBorder: lastGradientColor, lineWidth: 0.5)
                    .frame(width: thickness, height: thickness)
                    .shadow(color: .black.opacity(0.3),
                            radius: 2.5,
                            x: ringTipShadowOffset(radius: min(geo.size.width, geo.size.height) / 2).x,
                            y: ringTipShadowOffset(radius: min(geo.size.width, geo.size.height) / 2).y
                    )
                    .clipShape(
                        RingClipShape(
                            radius: min(geo.size.width, geo.size.height) / 2,
                            thickness: thickness
                        )
                    )
                    .opacity(tipOpacity)
                case .dynamic:
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            progressAngularGradient(colors: [.progressGreenStart, .progressGreenEnd]),
                            style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                        .rotationEffect(Angle(degrees: -90))
                        .opacity(progress < 0.5 ? 1 : 0)
                        .frame(
                            width: min(geo.size.width, geo.size.height),
                            height: min(geo.size.width, geo.size.height)
                        )
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            progressAngularGradient(colors: [.progressYellowStart, .progressYellowEnd]),
                            style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                        .rotationEffect(Angle(degrees: -90))
                        .opacity(progress >= 0.5 && progress < 1.0 ? 1 : 0)
                        .frame(
                            width: min(geo.size.width, geo.size.height),
                            height: min(geo.size.width, geo.size.height)
                        )
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            progressAngularGradient(colors: [.progressRedStart, .progressRedEnd]),
                            style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                        .rotationEffect(Angle(degrees: -90))
                        .opacity(progress >= 1.0 ? 1 : 0)
                        .frame(
                            width: min(geo.size.width, geo.size.height),
                            height: min(geo.size.width, geo.size.height)
                        )
                    RingCap(progress: progress,
                            ringRadius: min(geo.size.width, geo.size.height) / 2)
                    .fill(progress < 1.0 ? Color.progressYellowEnd : Color.progressRedEnd,
                          strokeBorder: progress < 1.0 ? Color.progressYellowEnd : Color.progressRedEnd,
                          lineWidth: 0.5)
                    .frame(width: thickness, height: thickness)
                    .shadow(color: .black.opacity(0.3),
                            radius: 2.5,
                            x: ringTipShadowOffset(radius: min(geo.size.width, geo.size.height) / 2).x,
                            y: ringTipShadowOffset(radius: min(geo.size.width, geo.size.height) / 2).y
                    )
                    .clipShape(
                        RingClipShape(
                            radius: min(geo.size.width, geo.size.height) / 2,
                            thickness: thickness
                        )
                    )
                    .opacity(tipOpacity)
                }
            }
            .frame(width: geo.size.width > geo.size.height ? geo.size.width : geo.size.height, height: geo.size.width > geo.size.height ? geo.size.height : geo.size.width)
        }
    }
    
    private var tipOpacity: Double {
        if progress < 0.95 {
            return 0
        } else {
            return 1
        }
    }
    
    private func ringTipShadowOffset(radius: Double) -> CGPoint {
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
