//
//  MantraCounterModeOverlayView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 27.07.2022.
//

import SwiftUI

struct MantraCounterModeOverlayView: View {
    @Binding var showBlink: Bool
    let viewModel: ReadsViewModel
    
    var body: some View {
        Color.gray
            .opacity(0.4)
            .ignoresSafeArea()
            .gesture(
                TapGesture(count: 2)
                    .onEnded {
                        viewModel.handleAdjusting(for: .rounds, with: 1)
                    }
                    .exclusively(
                        before:
                            TapGesture(count: 1)
                            .onEnded {
                                showBlink = true
                                afterDelay(0.05) { showBlink = false }
                                viewModel.handleAdjusting(for: .reads, with: 1)
                            }
                    )
            )
    }
}

struct MantraReaderModeOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        MantraCounterModeOverlayView(
            showBlink: .constant(false),
            viewModel: ReadsViewModel(
                PersistenceController.previewMantra,
                viewContext: PersistenceController.preview.container.viewContext
            )
        )
    }
}
