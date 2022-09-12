//
//  CircularProgressView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 17.06.2022.
//

import SwiftUI

struct CircularProgressView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @AppStorage("ringColor") private var ringColor: RingColor = .red
    @ObservedObject var viewModel: CircularProgressViewModel
    var isMantraCounterMode: Bool
    var frame: CGFloat?
    
    var body: some View {
        VStack {
            ZStack {
                PercentageRing(
                    ringWidth: 25, percent: viewModel.percent,
                    backgroundColor: ringColor.backgroundColor,
                    foregroundColors: ringColor.colors
                )
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
                            design: .rounded
                        )
                    )
                    .textSelection(.enabled)
                    .bold()
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
