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
    let radius: Double
    var width: Double
    
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
                    .stroke(backgroundColor, lineWidth: width)
                    .frame(width: radius * 2.0)
            }
            switch settings.ringColor {
            case .red, .yellow, .green:
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        progressAngularGradient(colors: foregroundColors),
                        style: StrokeStyle(lineWidth: width, lineCap: .round))
                    .rotationEffect(Angle(degrees: -90))
                    .frame(width: radius * 2.0)
                RingCap(progress: progress,
                        ringRadius: radius)
                .fill(lastGradientColor, strokeBorder: lastGradientColor, lineWidth: 0.5)
                .frame(width: width, height: width)
                .shadow(color: .black.opacity(0.3),
                        radius: 2.5,
                        x: ringTipShadowOffset.x,
                        y: ringTipShadowOffset.y
                )
                .clipShape(
                    RingClipShape(radius: radius, thickness: width)
                )
                .opacity(tipOpacity)
            case .dynamic:
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        progressAngularGradient(colors: [.progressGreenStart, .progressGreenEnd]),
                        style: StrokeStyle(lineWidth: width, lineCap: .round))
                    .rotationEffect(Angle(degrees: -90))
                    .frame(width: radius * 2.0)
                    .opacity(progress < 0.5 ? 1 : 0)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        progressAngularGradient(colors: [.progressYellowStart, .progressYellowEnd]),
                        style: StrokeStyle(lineWidth: width, lineCap: .round))
                    .rotationEffect(Angle(degrees: -90))
                    .frame(width: radius * 2.0)
                    .opacity(progress >= 0.5 && progress < 1.0 ? 1 : 0)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        progressAngularGradient(colors: [.progressRedStart, .progressRedEnd]),
                        style: StrokeStyle(lineWidth: width, lineCap: .round))
                    .rotationEffect(Angle(degrees: -90))
                    .frame(width: radius * 2.0)
                    .opacity(progress >= 1.0 ? 1 : 0)
                RingCap(progress: progress,
                        ringRadius: radius)
                .fill(progress < 1.0 ? Color.progressYellowEnd : Color.progressRedEnd,
                      strokeBorder: progress < 1.0 ? Color.progressYellowEnd : Color.progressRedEnd,
                      lineWidth: 0.5)
                .frame(width: width, height: width)
                .shadow(color: .black.opacity(0.3),
                        radius: 2.5,
                        x: ringTipShadowOffset.x,
                        y: ringTipShadowOffset.y
                )
                .clipShape(
                    RingClipShape(radius: radius, thickness: width)
                )
                .opacity(tipOpacity)
            }
        }
        .aspectRatio(1, contentMode: .fill)
        .frame(width: size, height: size)
    }
    
    private var size: Double {
        return radius * 2 + width
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
