//
//  ReadsViewModel.swift
//  MantraReader
//
//  Created by Александр Воробьев on 21.06.2022.
//

import SwiftUI
import Combine
import CoreData

enum AdjustingType {
    case reads
    case rounds
    case value
    case goal
}

enum UndoType {
    case value
    case goal
}

@MainActor
final class ReadsViewModel: ObservableObject {
    @Published var mantra: Mantra
    @Published var displayedReads: Double
    @Published var displayedGoal: Double
    @Published var progress: Double
    @Published var isAnimated: Bool = false
    @Published var undoHistory: [(value: Int32, type: UndoType)] = []
    
    var title: String { mantra.title ?? "" }
    var image: UIImage {
        if let data = mantra.image, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: Constants.defaultImage)!
        }
    }
    var favoriteBarImage: String { mantra.isFavorite ? "star.slash" : "star" }
    
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
    
    func toggleFavorite() {
        mantra.isFavorite.toggle()
        saveContext()
    }
    
    func isValidUpdatingNumber(for text: String?, adjustingType: AdjustingType?) -> Bool {
        guard
            let alertText = text,
            let alertNumber = UInt32(alertText),
            let adjustingType
        else { return false }
        
        switch adjustingType {
        case .reads:
            return 0...1_000_000 ~= UInt32(mantra.reads) + alertNumber
        case .rounds:
            let multiplied = alertNumber.multipliedReportingOverflow(by: 108)
            if multiplied.overflow {
                return false
            } else {
                return 0...1_000_000 ~= UInt32(mantra.reads) + multiplied.partialValue
            }
        case .goal, .value:
            return 0...1_000_000 ~= alertNumber
        }
    }
    
    func alertTitle(for adjustingType: AdjustingType?) -> String {
        guard let adjustingType else { return "" }
        switch adjustingType {
        case .reads:
            return NSLocalizedString("Enter Readings Number", comment: "Alert Title on ReadsView")
        case .rounds:
            return NSLocalizedString("Enter Rounds Number", comment: "Alert Title on ReadsView")
        case .value:
            return NSLocalizedString("Set a New Readings Count", comment: "Alert Title on ReadsView")
        case .goal:
            return NSLocalizedString("Set a New Readings Goal", comment: "Alert Title on ReadsView")
        }
    }
    
    func alertActionTitle(for adjustingType: AdjustingType?) -> String {
        guard let adjustingType else { return "" }
        switch adjustingType {
        case .reads:
            return NSLocalizedString("Add", comment: "Alert Button on ReadsView")
        case .rounds:
            return NSLocalizedString("Add", comment: "Alert Button on ReadsView")
        case .value:
            return NSLocalizedString("Set", comment: "Alert Button on ReadsView")
        case .goal:
            return NSLocalizedString("Set", comment: "Alert Button on ReadsView")
        }
    }
    
    func handleAdjusting(for adjust: AdjustingType?, with number: Int32) {
        guard let adjust else { return }
        switch adjust {
        case .reads:
            undoHistory.append((mantra.reads, .value))
            handleReadsChanges(with: mantra.reads + number)
        case .rounds:
            undoHistory.append((mantra.reads, .value))
            handleReadsChanges(with: mantra.reads + number * 108)
        case .value:
            undoHistory.append((mantra.reads, .value))
            handleReadsChanges(with: number)
        case .goal:
            undoHistory.append((mantra.readsGoal, .goal))
            handleGoalChanges(with: number)
        }
    }
    
    private func handleReadsChanges(with value: Int32) {
        adjustMantraReads(with: value)
        animateReadsChanges()
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
    
    private func handleGoalChanges(with value: Int32) {
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
