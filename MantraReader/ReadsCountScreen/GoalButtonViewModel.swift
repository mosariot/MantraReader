//
//  GoalButtonViewModel.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 18.07.2022.
//

import SwiftUI
import Combine

@MainActor
final class GoalButtonViewModel: ObservableObject {
    @Published var mantra: Mantra
    @Published var displayedGoal: Double
    
    private var timerSubscription: Cancellable?
    
    init(_ mantra: Mantra) {
        self.mantra = mantra
        self.displayedGoal = Double(mantra.readsGoal)
    }
    
    func updateForMantraChanges() {
        if Int32(displayedGoal) != mantra.readsGoal {
            animateChanges()
        }
    }
    
    private func animateChanges() {
        let deltaGoal = Double(mantra.readsGoal) - displayedGoal
        timerSubscription = Timer.publish(every: Constants.animationTime / 100, on: .main, in: .common)
            .autoconnect()
            .scan(0) { elapsedTime, _ in elapsedTime + Constants.animationTime / 100 }
            .sink { elapsedTime in
                if elapsedTime < Constants.animationTime {
                    self.displayedGoal += deltaGoal / 100.0
                } else {
                    self.displayedGoal = Double(self.mantra.readsGoal)
                    self.timerSubscription?.cancel()
                }
            }
    }
}
