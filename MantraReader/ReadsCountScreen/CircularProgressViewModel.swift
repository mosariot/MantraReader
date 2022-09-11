//
//  CircularProgressViewModel.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 18.07.2022.
//

import SwiftUI

@MainActor
final class CircularProgressViewModel: ObservableObject {
    @Published var mantra: Mantra
    @Published var previousReads: Int32
    @Published var currentReads: Int32
    @Published var progress: Double
    @Published var isAnimated: Bool = false
    private var readsGoal: Int32
    var percent: Double {
        var result: Double
        if progress > 10 {
            let threeDigitsAfterComma = Double(round(1000*progress)/1000) - progress.rounded(.down)
            result = 100 + threeDigitsAfterComma * 100
        } else {
            result = progress * 100
        }
        return result
    }
    
    
    init(_ mantra: Mantra) {
        self.mantra = mantra
        self.previousReads = mantra.reads
        self.currentReads = 0
        self.readsGoal = mantra.readsGoal
        self.progress = Double(mantra.reads) / Double(mantra.readsGoal)
    }
    
    func updateForMantraChanges() {
        if previousReads != mantra.reads || readsGoal != mantra.readsGoal {
            if abs(previousReads - mantra.reads) == 1 {
                progress = Double(mantra.reads) / Double(mantra.readsGoal)
                currentReads += mantra.reads - previousReads
                previousReads = mantra.reads
            } else {
                progress = Double(mantra.reads) / Double(mantra.readsGoal)
                currentReads += mantra.reads - previousReads
                previousReads = mantra.reads
                readsGoal = mantra.readsGoal
                isAnimated = true
                afterDelay(Constants.animationTime) { self.isAnimated = false }
            }
        }
    }
}
