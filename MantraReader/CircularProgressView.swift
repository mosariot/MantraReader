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
    var displayedGoal: Double
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
                    .pink,
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
                .font(.largeTitle)
                .bold()
            }
            .frame(maxHeight: 450)
            Text("Current goal: \(displayedGoal, specifier: "%.0f")")
            .foregroundColor(.gray)
            .padding()
        }
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(progress: 0.4, displayedNumber: 250, displayedGoal: 625, isAnimated: true)
            .previewLayout(.fixed(width: 300, height: 300))
            .padding()
            .previewDisplayName("Circular Progress View")
    }
}
