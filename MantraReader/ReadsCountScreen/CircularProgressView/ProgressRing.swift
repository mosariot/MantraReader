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
                    ProgressArc(
                        progress: progress,
                        colors: foregroundColors,
                        thickness: thickness,
                        frame: geo.size
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
                    ProgressArc(
                        progress: progress,
                        colors: Color.firstProgressTier,
                        thickness: thickness,
                        frame: geo.size
                    )
                    .opacity(progress < 0.5 ? 1 : 0)
                    ProgressArc(
                        progress: progress,
                        colors: Color.secondProgressTier,
                        thickness: thickness,
                        frame: geo.size
                    )
                    .opacity(progress >= 0.5 && progress < 1.0 ? 1 : 0)
                    ProgressArc(
                        progress: progress,
                        colors: Color.thirdProgressTier,
                        thickness: thickness,
                        frame: geo.size
                    )
                    .opacity(progress >= 1.0 ? 1 : 0)
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
            .frame(width: geo.size.width, height: geo.size.height)
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
