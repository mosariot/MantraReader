//
//  MantraReaderModeOverlayView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 27.07.2022.
//

import SwiftUI

struct MantraReaderModeOverlayView: View {
    @Binding var showBlink: Bool
    let viewModel: ReadsViewModel
    let lightHapticGenerator: UIImpactFeedbackGenerator
    
    
    var body: some View {
        Color.gray
            .opacity(0.4)
            .ignoresSafeArea()
            .gesture(
                TapGesture(count: 2)
                    .onEnded {
                        lightHapticGenerator.impactOccurred()
                        viewModel.handleAdjusting(for: .rounds, with: 1)
                    }
                    .exclusively(
                        before:
                            TapGesture(count: 1)
                            .onEnded {
                                showBlink = true
                                afterDelay(0.05) { showBlink = false }
                                lightHapticGenerator.impactOccurred()
                                viewModel.handleAdjusting(for: .reads, with: 1)
                            }
                    )
            )
    }
}

struct MantraReaderModeOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        MantraReaderModeOverlayView(
            showBlink: .constant(false),
            viewModel: ReadsViewModel(
                PersistenceController.previewMantra,
                viewContext: PersistenceController.preview.container.viewContext
            ),
            lightHapticGenerator: UIImpactFeedbackGenerator(style: .light)
        )
    }
}
