//
//  ReadsViewModel.swift
//  MantraReader
//
//  Created by Александр Воробьев on 21.06.2022.
//

import SwiftUI
import Combine
import CoreData

enum Congratulations {
    case half
    case full
}

@MainActor
final class ReadsViewModel: ObservableObject {
    @Published var mantra: Mantra
    @Published var undoHistory: [(value: Int32, type: UndoType)] = []
    @Published var congratulations: Congratulations?
    @Published var isPresentedCongratulations = false
    
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
    
    func adjudtingAlertTitle(for adjustingType: AdjustingType?) -> String {
        guard let adjustingType else { return "" }
        switch adjustingType {
        case .reads:
            return NSLocalizedString("Enter Readings Number", comment: "Enter value title for adjusting alert on ReadsView")
        case .rounds:
            return NSLocalizedString("Enter Rounds Number", comment: "Enter value title for adjusting alert on ReadsView")
        case .value:
            return NSLocalizedString("Set a New Readings Count", comment: "Set value title for adjusting alert on ReadsView")
        case .goal:
            return NSLocalizedString("Set a New Readings Goal", comment: "Set value title for adjusting alert on ReadsView")
        }
    }
    
    func adjustingAlertActionTitle(for adjustingType: AdjustingType?) -> String {
        guard let adjustingType else { return "" }
        switch adjustingType {
        case .reads:
            return NSLocalizedString("Add", comment: "Add button for adjusting alert on ReadsView")
        case .rounds:
            return NSLocalizedString("Add", comment: "Add button for adjusting alert on ReadsView")
        case .value:
            return NSLocalizedString("Set", comment: "Set button for adjusting alert on ReadsView")
        case .goal:
            return NSLocalizedString("Set", comment: "Set button for adjusting alert on ReadsView")
        }
    }
        
    func congratulationsAlertMessage(for congratulations: Congratulations?) -> String {
        guard let congratulations else { return "" }
        switch congratulations {
        case .half:
            return NSLocalizedString("You're half way to your goal!", comment: "Congratulations alert message on ReadsView - half goal")
        case .full:
            return NSLocalizedString("You've reached your goal!", comment: "Congratulations alert message on ReadsView - full goal")
        }
    }
    
    func handleUndo() {
        guard let lastAction = undoHistory.last else { return }
        switch lastAction.type {
        case .value:
            adjustMantraReads(with: lastAction.value)
            undoHistory.removeLast()
        case .goal:
            adjustMantraGoal(with: lastAction.value)
            undoHistory.removeLast()
        }
    }
    
    func handleAdjusting(for adjust: AdjustingType?, with value: Int32) {
        guard let adjust else { return }
        switch adjust {
        case .reads:
            undoHistory.append((mantra.reads, .value))
            checkForCongratulations(with: mantra.reads + value)
            adjustMantraReads(with: mantra.reads + value)
        case .rounds:
            undoHistory.append((mantra.reads, .value))
            checkForCongratulations(with: mantra.reads + value * 108)
            adjustMantraReads(with: mantra.reads + value * 108)
        case .value:
            undoHistory.append((mantra.reads, .value))
            checkForCongratulations(with: value)
            adjustMantraReads(with: value)
        case .goal:
            undoHistory.append((mantra.readsGoal, .goal))
            adjustMantraGoal(with: number)
        }
    }
    
    private func checkForCongratilations(with value: Int32) {
        if value >= mantra.readsGoal && mantra.reads <= mantra.readsGoal {
            congratulations = .half
            isPresentedCongratulations = true
        } else if value >= mantra.readsGoal / 2 && mantra.reads <= mantra.readsGoal / 2 {
            congratulations = .full
            isPresentedCongratulations = true
        }
    }
    
    private func adjustMantraReads(with value: Int32) {
        mantra.reads = value
        saveContext()
    }
    
    private func adjustMantraGoal(with value: Int32) {
        mantra.readsGoal = value
        saveContext()
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
