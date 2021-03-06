//
//  CircularProgressViewModel.swift
//  MantraReader
//
//  Created by Александр Воробьев on 18.07.2022.
//

import SwiftUI
import Combine

@MainActor
final class CircularProgressViewModel: ObservableObject {
    @Published var mantra: Mantra
    @Published var displayedReads: Double
    @Published var progress: Double
    @Published var isAnimated: Bool = false
    private var readsGoal: Int32
    
    private var timerSubscription: Cancellable?
    
    init(_ mantra: Mantra) {
        self.mantra = mantra
        self.displayedReads = Double(mantra.reads)
        self.readsGoal = mantra.readsGoal
        self.progress = Double(mantra.reads) / Double(mantra.readsGoal)
    }
    
    func updateForMantraChanges() {
        if Int32(displayedReads) != mantra.reads || readsGoal != mantra.readsGoal {
            readsGoal = mantra.readsGoal
            animateChanges()
        }
    }
    
    private func animateChanges() {
        isAnimated = true
        progress = Double(mantra.reads) / Double(mantra.readsGoal)
        let deltaReads = Double(mantra.reads) - displayedReads
        timerSubscription = Timer.publish(every: Constants.animationTime / 100, on: .main, in: .common)
            .autoconnect()
            .scan(0) { elapsedTime, _ in elapsedTime + Constants.animationTime / 100 }
            .sink { elapsedTime in
                if elapsedTime < Constants.animationTime {
                    self.displayedReads += deltaReads / 100.0
                } else {
                    self.displayedReads = Double(self.mantra.reads)
                    self.isAnimated = false
                    self.timerSubscription?.cancel()
                }
            }
    }
}
