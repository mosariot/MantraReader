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

    private var deltaReads: Double = 0
    private var elapsedTimeReads: Double = 0
    private var timerReadsSubscription: Cancellable?
    private var deltaGoal: Double = 0
    private var elapsedTimeGoal: Double = 0
    private var timerGoalSubscription: Cancellable?

    
    init(_ mantra: Mantra) {
        self.mantra = mantra
        self.displayedReads = Double(mantra.reads)
        self.displayedGoal = Double(mantra.goal)
        self.progress = Double(mantra.reads) / Double(mantra.goal)
    }
    
    func animateReadsChanges(with value: String) {
        isAnimated = true
        mantra.reads = Int32(value) ?? mantra.reads
        progress = Double(mantra.reads) / Double(mantra.goal)
        deltaReads = Double(mantra.reads) - displayedReads
        timerReadsSubscription = Timer.publish(every: Constants.animationTime / 100, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if self.elapsedTimeReads < Constants.animationTime {
                    self.displayedReads += Double(self.deltaReads) / 100.0
                    self.elapsedTimeReads += Constants.animationTime / 100
                } else {
                    self.displayedReads = Double(self.mantra.reads)
                    self.elapsedTimeReads = 0
                    self.isAnimated = false
                    self.timerReadsSubscription?.cancel()
                }
            }
    }
    
    func animateGoalsChanges(with value: String) {
        isAnimated = true
        mantra.goal = Int32(value) ?? mantra.goal
        progress = Double(mantra.reads) / Double(mantra.goal)
        deltaGoal = Double(mantra.goal) - displayedGoal
        timerGoalSubscription = Timer.publish(every: Constants.animationTime / 100, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if self.elapsedTimeGoal < Constants.animationTime {
                    self.displayedGoal += Double(self.deltaGoal) / 100.0
                    self.elapsedTimeGoal += Constants.animationTime / 100
                } else {
                    self.displayedGoal = Double(self.mantra.goal)
                    self.elapsedTimeGoal = 0
                    self.isAnimated = false
                    self.timerGoalSubscription?.cancel()
                }
            }
    }
}

