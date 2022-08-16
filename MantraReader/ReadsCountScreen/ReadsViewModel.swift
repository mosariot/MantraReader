//
//  ReadsViewModel.swift
//  MantraReader
//
//  Created by Александр Воробьев on 21.06.2022.
//

import SwiftUI
import Combine
import CoreData

@MainActor
final class ReadsViewModel: ObservableObject {
    static private var confettiTrigger: Int = 0
    @Published var mantra: Mantra
    @Published var undoHistory: [(value: Int32, type: UndoType)] = []
    @Published var congratulations: Congratulations?
    @Published var isPresentedCongratulations = false
    @Published var confettiTrigger: Int = 0
    private let congratulationsGenerator = UINotificationFeedbackGenerator()
    private let lightHapticGenerator = UIImpactFeedbackGenerator(style: .light)
    private let widgetManager = MantraWidgetManager()
    
    var title: String { mantra.title ?? "" }
    var image: UIImage {
        if let data = mantra.image, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: Constants.defaultImage)!
        }
    }
    var favoriteBarImage: String { mantra.isFavorite ? "star.fill" : "star" }
    
    private(set) var viewContext: NSManagedObjectContext
    
    private var timerReadsSubscription: Cancellable?
    private var timerGoalSubscription: Cancellable?
    
    init(_ mantra: Mantra, viewContext: NSManagedObjectContext) {
        self.mantra = mantra
        self.viewContext = viewContext
        self.confettiTrigger = Self.confettiTrigger
    }
    
    func toggleFavorite() {
        lightHapticGenerator.impactOccurred()
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
    
    func adjustingAlertTitle(for adjustingType: AdjustingType?) -> String {
        guard let adjustingType else { return "" }
        switch adjustingType {
        case .reads:
            return String(localized: "Enter Readings Number")
        case .rounds:
            return String(localized: "Enter Rounds Number")
        case .value:
            return String(localized: "Set a New Readings Count")
        case .goal:
            return String(localized: "Set a New Readings Goal")
        }
    }
    
    func adjustingAlertActionTitle(for adjustingType: AdjustingType?) -> String {
        guard let adjustingType else { return "" }
        switch adjustingType {
        case .reads:
            return String(localized: "Add")
        case .rounds:
            return String(localized: "Add")
        case .value:
            return String(localized: "Set")
        case .goal:
            return String(localized: "Set")
        }
    }
        
    func congratulationsAlertMessage(for congratulations: Congratulations?) -> String {
        guard let congratulations else { return "" }
        switch congratulations {
        case .half:
            return String(localized: "You're half way to your goal!")
        case .full:
            return String(localized: "You've reached your goal!")
        }
    }
    
    func handleUndo() {
        guard let lastAction = undoHistory.last else { return }
        lightHapticGenerator.impactOccurred()
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
            lightHapticGenerator.impactOccurred()
            adjustMantraGoal(with: value)
        }
    }
    
    private func checkForCongratulations(with value: Int32) {
        if mantra.reads < mantra.readsGoal && value >= mantra.readsGoal {
            congratulationsGenerator.notificationOccurred(.success)
            confettiTrigger += 1
            Self.confettiTrigger += 1
            afterDelay(Constants.animationTime + 1.8) {
                self.congratulations = .full
                self.isPresentedCongratulations = true
            }
            return
        }
        if mantra.reads < mantra.readsGoal/2 && mantra.readsGoal/2..<mantra.readsGoal ~= value {
            afterDelay(Constants.animationTime + 0.3) {
                self.congratulations = .half
                self.isPresentedCongratulations = true
            }
        }
        lightHapticGenerator.impactOccurred()
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
            widgetManager.updateWidgetData(viewContext: viewContext)
        } catch {
            fatalCoreDataError(error)
        }
    }
}
