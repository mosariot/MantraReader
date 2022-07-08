//
//  ReadsViewModel.swift
//  MantraReader
//
//  Created by Александр Воробьев on 21.06.2022.
//

import SwiftUI
import Combine
import CoreData

final class ReadsViewModel: ObservableObject {
    @Published var mantra: Mantra
    @Published var displayedReads: Double
    @Published var displayedGoal: Double
    @Published var progress: Double
    @Published var isAnimated: Bool = false
    
    private(set) var title: String { mantra.title ?? "" }
    private(set) var image: UIImage {
        if let data = mantra.image, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: Constants.defaultImage)!
        }
    }
    
    private var viewContext: NSManagedObjectContext

    private var timerReadsSubscription: Cancellable?
    private var timerGoalSubscription: Cancellable?

    init(_ mantra: Mantra, viewContext: NSManagedObjectContext) {
        self.mantra = mantra
        self.displayedReads = Double(mantra.reads)
        self.displayedGoal = Double(mantra.readsGoal)
        self.progress = Double(mantra.reads) / Double(mantra.readsGoal)
        self.viewContext = viewContext
    }
    
    func alertTitle(for adjust: AdjustingType?) -> String {
        guard let adjust else { return "Enter a value" }
        switch adjust {
        case .reads: return "Enter readings number"
        case .rounds: return "Enter rounds number"
        case .value: return "Set a new readings count"
        case .goal: return "Set a new readings goal"
        }
    }
    
    func buttonTitle(for adjust: AdjustingType) -> String {
        switch adjust {
        case .reads, .rounds: return "Add"
        case .value, .goal: return "Set"
    }
    
    func handleAdjusting(for adjust: AdjustingType, with number: Int32) {
        switch adjust {
        case .reads: handleReadsChanges(with: mantra.reads + number)
        case .rounds: handleReadsChanges(with: mantra.reads + number * 108)
        case .value: handleReadsChanges(with: number)
        case .goal: handleGoalChanges(with: number)
    }
    
    func isAllowedAdjusting(for adjust: AdjustingType, with number: Int32) -> Bool {
        switch adjust {
        case .reads: return 0...1_000_000 ~= (mantra.reads + number)
        case .rounds:
            let multiplied = number.multipliedReportingOverflow(by: 108)
            if multiplied.overflow {
                return false
            } else {
                return 0...1_000_000 ~= mantra.reads + multiplied.partialValue
            }
        case .value, .goal: return 0...1_000_000 ~= number
    }
    
    func handleReadsChanges(with value: Int32) {
        adjustMantraReads(with: value)
        animateReadsChange()
    }

    private func adjustMantraReads(with value: Int32) {
        mantra.reads = value
        saveContext()
    }
        
    private func animateReadsChanges() {
        isAnimated = true
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
         
    func handleGoalChanges(with value: Int32) {
        adjustMantraGoal(with: value)
        animateGoalChanges()
    }
    
    private func adjustMantraGoal(with value: Int32) {
        mantra.readsGoal = value
        saveContext()
    }
    
    private func animateGoalChanges() {
        isAnimated = true
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
    
    private func saveContext() {
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        } catch {
            fatalCoreDataError(error)
        }
    }
}
