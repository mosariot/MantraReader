//
//  ReadsViewModel.swift
//  MantraReader
//
//  Created by Александр Воробьев on 21.06.2022.
//

import Foundation
import Combine

final class ReadsViewModel: ObservableObject {
    @Published var mantra: Mantra
    @Published var displayedReads: Double
    @Published var displayedGoal: Double
    @Published var progress: Double
    @Published var isAnimated: Bool = false

    private var timerReadsSubscription: Cancellable?
    private var timerGoalSubscription: Cancellable?

    
    init(_ mantra: Mantra) {
        self.mantra = mantra
        self.displayedReads = Double(mantra.reads)
        self.displayedGoal = Double(mantra.readsGoal)
        self.progress = Double(mantra.reads) / Double(mantra.readsGoal)
    }
    
    func animateReadsChanges(with value: String) {
        isAnimated = true
        mantra.reads = Int32(value) ?? mantra.reads
        progress = Double(mantra.reads) / Double(mantra.readsGoal)
        let deltaReads = Double(mantra.reads) - displayedReads
        timerReadsSubscription = Timer.publish(every: Constants.animationTime / 100, on: .main, in: .common)
            .autoconnect()
            .scan(0) { elapsedTime, _ in elapsedTime + Constants.animationTime / 100 }
            .sink { elapsedTime in
                if elapsedTime < Constants.animationTime {
                    self.displayedReads += deltaReads / 100.0
                } else {
                    self.displayedReads = Double(self.mantra.reads)
                    self.isAnimated = false
                    self.timerReadsSubscription?.cancel()
                }
            }
    }
    
    func animateGoalsChanges(with value: String) {
        isAnimated = true
        mantra.readsGoal = Int32(value) ?? mantra.readsGoal
        progress = Double(mantra.reads) / Double(mantra.readsGoal)
        let deltaGoal = Double(mantra.readsGoal) - displayedGoal
        timerGoalSubscription = Timer.publish(every: Constants.animationTime / 100, on: .main, in: .common)
            .autoconnect()
            .scan(0) { elapsedTime, _ in elapsedTime + Constants.animationTime / 100 }
            .sink { elapsedTime in
                if elapsedTime < Constants.animationTime {
                    self.displayedGoal += deltaGoal / 100.0
                } else {
                    self.displayedGoal = Double(self.mantra.readsGoal)
                    self.isAnimated = false
                    self.timerGoalSubscription?.cancel()
                }
            }
    }
}

