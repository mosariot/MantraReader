//
//  CircularProgressViewModel.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 18.07.2022.
//

import SwiftUI
import Combine

@MainActor
final class CircularProgressViewModel: ObservableObject {
    @Published var mantra: Mantra
    @Published var displayedReads: Double
    @Published var currentDisplayedReads: Double
    @Published var progress: Double
    @Published var isAnimated: Bool = false
    private var readsGoal: Int32
    var percent: Double {
        var result: Double
        let threeDigitsAfterComma = Int(progress * 1000) % Int(progress)
        if progress > 10 {
            result = 100 + Double(threeDigitsAfterComma) / 10
        } else {
            result = progress * 100
        }
        return result
    }
    
    private var timerSubscription: Cancellable?
    
    init(_ mantra: Mantra) {
        self.mantra = mantra
        self.displayedReads = Double(mantra.reads)
        self.currentDisplayedReads = 0
        self.readsGoal = mantra.readsGoal
        self.progress = Double(mantra.reads) / Double(mantra.readsGoal)
    }
    
    func updateForMantraChanges() {
        if Int32(displayedReads) != mantra.reads || readsGoal != mantra.readsGoal {
            if abs(Int32(displayedReads) - mantra.reads) == 1 {
                progress = Double(mantra.reads) / Double(mantra.readsGoal)
                currentDisplayedReads += Double(mantra.reads) - displayedReads
                displayedReads = Double(mantra.reads)
            } else {
                readsGoal = mantra.readsGoal
                animateChanges()
            }
        }
    }
    
    private func animateChanges() {
        isAnimated = true
        progress = Double(mantra.reads) / Double(mantra.readsGoal)
        let deltaReads = Double(mantra.reads) - displayedReads
        timerSubscription = Timer.publish(every: Constants.animationTime / 100, on: .main, in: .common)
            .autoconnect()
            .scan(0) { elapsedTime, _ in elapsedTime + Constants.animationTime / 101 }
            .sink { elapsedTime in
                if elapsedTime < Constants.animationTime {
                    self.displayedReads += deltaReads / 100.0
                    self.currentDisplayedReads += deltaReads / 100.0
                } else {
                    self.displayedReads = Double(self.mantra.reads)
                    self.isAnimated = false
                    self.timerSubscription?.cancel()
                }
            }
    }
}
