//
//  CircularProgressView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 17.06.2022.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double
    var displayedNumber: Double
    var isAnimated: Bool
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(
                        .gray.opacity(0.5),
                        lineWidth: 20
                    )
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        strokeColor(for: progress),
                        style: StrokeStyle(
                            lineWidth: 20,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(
                        isAnimated ?
                        Animation.easeOut(duration: Constants.animationTime) :
                            Animation.linear(duration: 0.01),
                        value: progress
                    )
                Text("\(displayedNumber, specifier: "%.0f")")
                    .font(.system(.largeTitle, design: .rounded, weight: .medium))
                    .textSelection(.enabled)
                    .bold()
                    .dynamicTypeSize(.medium)
            }
        }
    }
    
    private func strokeColor(for progress: Double) -> Color {
        switch progress {
        case 0..<0.5: return .green
        case 0.5..<1.0: return .orange
        case 1.0...: return .pink
        default: return .green
        }
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(progress: 0.4, displayedNumber: 250, isAnimated: true)
            .previewLayout(.fixed(width: 300, height: 300))
            .padding()
            .previewDisplayName("Circular Progress View")
    }
}
