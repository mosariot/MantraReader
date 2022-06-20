//
//  CircularProgressView.swift
//  MantraReaderIdeas
//
//  Created by Александр Воробьев on 17.06.2022.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double
    var displayedNumber: Double
    var isAnimated: Bool = true
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    .gray.opacity(0.5),
                    lineWidth: 30
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    .pink,
                    style: StrokeStyle(
                        lineWidth: 30,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(
                    isAnimated ? .easeOut(duration: 1) : .none,
                    value: progress
                )
            Text("\(displayedNumber, specifier: "%.0f")")
                .font(.largeTitle)
                .bold()
        }
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(progress: 0.4, displayedNumber: 250)
            .frame(width: 300, height: 300)
    }
}
