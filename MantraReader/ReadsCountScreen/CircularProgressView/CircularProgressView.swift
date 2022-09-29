//
//  CircularProgressView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 17.06.2022.
//

import SwiftUI

struct CircularProgressView: View {
#if os(iOS)
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    var frame: CGFloat?
#endif
    @ObservedObject var viewModel: CircularProgressViewModel
    var isMantraCounterMode: Bool
    private var thickness: Double {
#if os(iOS)
        25
#elseif os(watchOS)
        15
#endif
    }
    
    var body: some View {
        VStack {
            ZStack {
                ProgressRing(progress: viewModel.percent, thickness: thickness)
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
#if os(iOS)
                    .font(
                        .system(
                            verticalSizeClass == .compact ? .title : .largeTitle,
                            design: .rounded,
                            weight: .bold
                        )
                    )
                    .textSelection(.enabled)
                    .offset(x: 0, y: isMantraCounterMode ? -(frame ?? 0) / 6 : 0)
#elseif os(watchOS)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .opacity(isMantraCounterMode ? 0 : 1)
#endif
                    .dynamicTypeSize(.xLarge)
                Text("Current Reads")
                    .numberAnimation(Int32(viewModel.currentReads))
                    .animation(
                        viewModel.isAnimated ?
                            Animation.easeInOut(duration: Constants.animationTime) :
                            Animation.linear(duration: 0.01),
                        value: viewModel.mantra.reads)
#if os(iOS)
                    .font(
                        .system(
                            verticalSizeClass == .compact ? .title : .largeTitle,
                            design: .rounded,
                            weight: .bold
                        )
                    )
                    .textSelection(.enabled)
                    .offset(x: 0, y: isMantraCounterMode ? (frame ?? 0) / 6 : 0)
#elseif os(watchOS)
                    .font(.system(.title2, design: .rounded, weight: .bold))
#endif
                    .foregroundColor(.accentColor)
                    .dynamicTypeSize(.xLarge)
                    .opacity(isMantraCounterMode ? 1 : 0)
            }
        }
        .onReceive(viewModel.mantra.objectWillChange) { _ in
            withAnimation {
                viewModel.updateForMantraChanges()
            }
        }
    }
}
