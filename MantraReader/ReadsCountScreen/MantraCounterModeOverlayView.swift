//
//  MantraCounterModeOverlayView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 27.07.2022.
//

import SwiftUI

struct MantraCounterModeOverlayView: View {
    @Binding var showBlink: Bool
    let viewModel: ReadsViewModel
    #if os(watchOS)
    @Binding var previousReads: Int32
    #endif
    
    var body: some View {
        Color.gray
            .opacity(0.4)
            .ignoresSafeArea()
            .gesture(
                TapGesture(count: 2)
                    .onEnded {
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
    }
}
