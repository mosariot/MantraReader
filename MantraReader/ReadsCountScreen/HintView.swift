//
//  HintView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 26.07.2022.
//

import SwiftUI

struct HintView: View {
    @Binding var showHint: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.gray)
                .cornerRadius(10)
            VStack {
                Text("\(Image(systemName: "hand.draw")) = \(Image(systemName: "plus.circle"))")
                    .scaledToFill()
                    .lineLimit(1)
                    .padding(.vertical, 2)
                Text("\(Image(systemName: "hand.draw")) \(Image(systemName: "hand.draw")) = \(Image(systemName: "arrow.clockwise.circle"))")
                    .scaledToFill()
                    .lineLimit(1)
                    .padding(.vertical, 2)
            }
            .padding(.horizontal, 5)
            .foregroundColor(.white)
        }
        .opacity(0.9)
        .frame(width: 100, height: 100)
        .onAppear {
            afterDelay(1.5) { showHint = false }
        }
#if os(iOS)
        .offset(y: -100)
#endif
        .transition(
            .scale(scale: 1.3, anchor: .top)
            .combined(with: .opacity)
            .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.5, blendDuration: 0.2))
        )
    }
}
