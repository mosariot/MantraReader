//
//  CircularProgressView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 17.06.2022.
//

import SwiftUI

struct CircularProgressView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @ObservedObject var viewModel: CircularProgressViewModel
    var isMantraCounterMode: Bool
    var frame: CGFloat?
    
    var body: some View {
        VStack {
            ZStack {
                PercentageRing(
                    ringWidth: 20, percent: viewModel.progress * 100,
                    backgroundColor: .red.opacity(0.2),
                    foregroundColors: [
                        Color("progressStart"),
                        Color("progressEnd")
                    ]
                )
                .animation(
                    viewModel.isAnimated ?
                        Animation.easeOut(duration: Constants.animationTime) :
                        Animation.linear(duration: 0.01),
                    value: viewModel.progress
                )
                Text("\(viewModel.displayedReads, specifier: "%.0f")")
                    .font(
                        .system(
                            verticalSizeClass == .compact ? .title : .largeTitle,
                            design: .rounded
                        )
                    )
                    .textSelection(.enabled)
                    .bold()
                    .dynamicTypeSize(.xLarge)
                    .offset(x: 0, y: isMantraCounterMode ? -(frame ?? 0) / 6 : 0)
                Text("\(viewModel.currentDisplayedReads, specifier: "%.0f")")
                    .font(
                        .system(
                            verticalSizeClass == .compact ? .title : .largeTitle,
                            design: .rounded
                        )
                    )
                    .textSelection(.enabled)
                    .bold()
                    .foregroundColor(.accentColor)
                    .dynamicTypeSize(.xLarge)
                    .opacity(isMantraCounterMode ? 1 : 0)
                    .offset(x: 0, y: isMantraCounterMode ? (frame ?? 0) / 6 : 0)
            }
        }
        .onReceive(viewModel.mantra.objectWillChange) { _ in
            withAnimation {
                viewModel.updateForMantraChanges()
            }
        }
    }
}
