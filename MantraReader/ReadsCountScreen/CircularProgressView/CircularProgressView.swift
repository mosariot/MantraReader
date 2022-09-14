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
                PercentageRing(ringWidth: 25, percent: viewModel.percent)
                .animation(
                    viewModel.isAnimated ?
                        Animation.easeOut(duration: Constants.animationTime) :
                        Animation.linear(duration: 0.01),
                    value: viewModel.progress
                )
                Text("Reads")
                    .numberAnimation(viewModel.mantra.reads)
                    .animation(
                        viewModel.isAnimated ?
                            Animation.easeInOut(duration: Constants.animationTime) :
                            Animation.linear(duration: 0.01),
                        value: viewModel.mantra.reads)
                    .font(
                        .system(
                            verticalSizeClass == .compact ? .title : .largeTitle,
                            design: .rounded,
                            weight: .bold
                        )
                    )
                    .textSelection(.enabled)
                    .dynamicTypeSize(.xLarge)
                    .offset(x: 0, y: isMantraCounterMode ? -(frame ?? 0) / 6 : 0)
                Text("Current Reads")
                    .numberAnimation(Int32(viewModel.currentReads))
                    .animation(
                        viewModel.isAnimated ?
                            Animation.easeInOut(duration: Constants.animationTime) :
                            Animation.linear(duration: 0.01),
                        value: viewModel.mantra.reads)
                    .font(
                        .system(
                            verticalSizeClass == .compact ? .title : .largeTitle,
                            design: .rounded,
                            weight: .bold
                        )
                    )
                    .textSelection(.enabled)
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
