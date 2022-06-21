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
    @Published var displayedGoal: Int32
    @Published var progress: Double
    @Published var isAnimated: Bool = false
    private var deltaReads: Double = 0
    private var elapsedTime: Double = 0
    private var timer = Timer.publish(every: Constants.animationTime / 100, on: .main, in: .common)
    private var timerSubscription: Cancellable?
    
    init(_ mantra: Mantra) {
        self.mantra = mantra
        self.displayedReads = Double(mantra.reads)
        self.displayedGoal = mantra.goal
        self.progress = Double(mantra.reads) / Double(mantra.goal)
    }
    
    func animateReadsChanges(with value: String) {
        isAnimated = true
        mantra.reads = Int32(value) ?? mantra.reads
        progress = Double(mantra.reads) / Double(mantra.goal)
        deltaReads = Double(mantra.reads) - displayedReads
        timerSubscription = Timer.publish(every: Constants.animationTime / 100, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if self.elapsedTime < Constants.animationTime {
                    self.displayedReads += Double(self.deltaReads) / 100.0
                    self.elapsedTime += Constants.animationTime / 100
                } else {
                    self.displayedReads = Double(self.mantra.reads)
                    self.elapsedTime = 0
                    self.isAnimated = false
                    self.timerSubscription?.cancel()
                }
            }
    }
    
    func animateGoalsChanges(with value: String) {
        isAnimated = true
        mantra.goal = Int32(value) ?? mantra.goal
        progress = Double(mantra.reads) / Double(mantra.goal)
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.animationTime) {
            self.isAnimated = false
        }
    }
}

