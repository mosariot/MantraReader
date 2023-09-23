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
#if os(iOS)
    @ObservedObject var viewModel: CircularProgressViewModel
#elseif os(watchOS)
    @StateObject var viewModel: CircularProgressViewModel
    @State private var date = Date.now
#endif
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
                            (UIDevice.current.userInterfaceIdiom == .pad && (frame ?? 0 < 150)) ? .headline :
                                (UIDevice.current.userInterfaceIdiom == .pad && (frame ?? 0 < 200)) ? .title :
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
                Text("Current readings:")
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
#if os(watchOS)
                Text("\(date, style: .timer)")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.gray)
                    .offset(x: 0, y: 35)
                    .opacity(isMantraCounterMode ? 1 : 0)
#endif
            }
        }
#if os(watchOS)
        .onChange(of: isMantraCounterMode) { newValue in
            if newValue {
                date = Date.now
            }
        }
#endif
        .onReceive(viewModel.mantra.objectWillChange) { _ in
            withAnimation {
                viewModel.updateForMantraChanges()
            }
        }
    }
}
