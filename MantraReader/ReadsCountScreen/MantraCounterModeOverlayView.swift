//
//  MantraCounterModeOverlayView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 27.07.2022.
//

import SwiftUI

struct MantraCounterModeOverlayView: View {
    @State private var showBlink = false
    let viewModel: ReadsViewModel
    
    var body: some View {
        ZStack {
            Color.gray
                .opacity(0.4)
                .ignoresSafeArea()
                .gesture(
                    TapGesture(count: 2)
                        .onEnded {
                            showBlink = true
                            afterDelay(0.05) { showBlink = false }
#if os(watchOS)
                            WKInterfaceDevice.current().play(.click)
#endif
                            viewModel.handleAdjusting(for: .rounds, with: 1)
                        }
                        .exclusively(
                            before:
                                TapGesture(count: 1)
                                .onEnded {
                                    showBlink = true
                                    afterDelay(0.05) { showBlink = false }
#if os(watchOS)
                                    WKInterfaceDevice.current().play(.click)
#endif
                                    viewModel.handleAdjusting(for: .reads, with: 1)
                                }
                        )
                )
            if showBlink {
                BlinkView()
            }
        }
    }
}
