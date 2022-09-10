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
    @Published var previousGoal: Int32
    @Published var isAnimated: Bool = false
    
    init(_ mantra: Mantra) {
        self.mantra = mantra
        self.previousGoal = mantra.readsGoal
    }
    
    func updateForMantraChanges() {
        if previousGoal != mantra.readsGoal {
            previousGoal = mantra.readsGoal
            isAnimated = true
            afterDelay(Constants.animationTime) { self.isAnimated = false }
        }
    }
}
