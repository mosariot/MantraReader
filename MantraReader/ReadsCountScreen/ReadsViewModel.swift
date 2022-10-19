//
//  ReadsViewModel.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 21.06.2022.
//

import SwiftUI
import CoreData

@MainActor
final class ReadsViewModel: ObservableObject {
    static private var confettiTrigger: Int = 0
    @Published var mantra: Mantra
#if os(iOS)
    @Published var undoHistory: [(value: Int32, type: UndoType)] = []
    private let congratulationsGenerator = UINotificationFeedbackGenerator()
    private let lightHapticGenerator = UIImpactFeedbackGenerator(style: .light)
#endif
    @Published var congratulations: Congratulations?
    @Published var isPresentedCongratulations = false
    @Published var isAboutToShowCongratulations = false
    @Published var confettiTrigger: Int = 0
    
#if os(iOS)
    var title: String { mantra.title ?? "" }
    var image: UIImage {
        if let data = mantra.image, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: Constants.defaultImage)!
        }
    }
    var favoriteBarImage: String { mantra.isFavorite ? "star.slash" : "star" }
    var favoriteBarTitle: String { mantra.isFavorite ? String(localized: "Unfavorite") : String(localized: "Favorite") }
#endif
    
#if os(watchOS)
    private var session: WKExtendedRuntimeSession!
#endif
    
    private var dataManager: DataManager
    
    init(_ mantra: Mantra, dataManager: DataManager) {
        self.mantra = mantra
        self.dataManager = dataManager
        self.confettiTrigger = Self.confettiTrigger
    }
    
#if os(iOS)
    func toggleFavorite() {
        lightHapticGenerator.impactOccurred()
        mantra.isFavorite.toggle()
        dataManager.saveData()
    }
    
    func isValidUpdatingNumber(for text: String?, adjustingType: AdjustingType?) -> Bool {
        guard
            let alertText = text,
            let alertNumber = UInt32(alertText),
            let adjustingType
        else { return false }
        
        switch adjustingType {
        case .reads:
            return 0...2_000_001 ~= UInt32(mantra.reads) + alertNumber
        case .rounds:
            let multiplied = alertNumber.multipliedReportingOverflow(by: 108)
            if multiplied.overflow {
                return false
            } else {
                return 0...2_000_001 ~= UInt32(mantra.reads) + multiplied.partialValue
            }
        case .goal, .value:
            return 0...2_000_001 ~= alertNumber
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
#endif
    
    func congratulationsAlertMessage(for congratulations: Congratulations?) -> String {
        guard let congratulations else { return "" }
        switch congratulations {
        case .half:
            return String(localized: "You're half way to your goal!")
        case .full:
            return String(localized: "You've reached your goal!")
        }
    }
    
    func handleAdjusting(for adjust: AdjustingType?, with value: Int32) {
        guard let adjust else { return }
#if os(watchOS)
        WKInterfaceDevice.current().play(.click)
#endif
        switch adjust {
        case .reads:
#if os(iOS)
            undoHistory.append((mantra.reads, .value))
            checkForCongratulations(with: mantra.reads + value)
#endif
            adjustMantraReads(with: mantra.reads + value)
        case .rounds:
#if os(iOS)
            undoHistory.append((mantra.reads, .value))
            checkForCongratulations(with: mantra.reads + value * 108)
#endif
            adjustMantraReads(with: mantra.reads + value * 108)
        case .value:
#if os(iOS)
            undoHistory.append((mantra.reads, .value))
            checkForCongratulations(with: value)
#endif
            adjustMantraReads(with: value)
        case .goal:
#if os(iOS)
            undoHistory.append((mantra.readsGoal, .goal))
            lightHapticGenerator.impactOccurred()
#elseif os(watchOS)
            WKInterfaceDevice.current().play(.click)
#endif
            adjustMantraGoal(with: value)
        }
#if os(iOS)
        mantra.insertShortcutItem()
#endif
    }
    
#if os(iOS)
    private func checkForCongratulations(with value: Int32) {
        if mantra.reads < mantra.readsGoal && value >= mantra.readsGoal {
            congratulationsGenerator.notificationOccurred(.success)
            confettiTrigger += 1
            Self.confettiTrigger += 1
            isAboutToShowCongratulations = true
            afterDelay(Constants.animationTime + 1.8) {
                self.congratulations = .full
                self.isPresentedCongratulations = true
                self.isAboutToShowCongratulations = false
            }
            return
        }
        if mantra.reads < mantra.readsGoal/2 && mantra.readsGoal/2..<mantra.readsGoal ~= value {
            isAboutToShowCongratulations = true
            afterDelay(Constants.animationTime + 0.3) {
                self.congratulations = .half
                self.isPresentedCongratulations = true
                self.isAboutToShowCongratulations = false
            }
        }
        lightHapticGenerator.impactOccurred()
    }
    
#elseif os(watchOS)
    func checkForCongratulationsOnWatch(with value: Int32, noDelay: Bool = false) {
        if mantra.reads - value < mantra.readsGoal && mantra.reads >= mantra.readsGoal {
            WKInterfaceDevice.current().play(.success)
            confettiTrigger += 1
            Self.confettiTrigger += 1
            isAboutToShowCongratulations = true
            afterDelay(Constants.animationTime + 1.8) {
                self.congratulations = .full
                self.isPresentedCongratulations = true
                self.isAboutToShowCongratulations = false
            }
            return
        }
        if mantra.reads - value < mantra.readsGoal/2 && mantra.readsGoal/2..<mantra.readsGoal ~= mantra.reads {
            isAboutToShowCongratulations = true
            afterDelay(noDelay ? 0.3 : Constants.animationTime + 0.3) {
                self.congratulations = .half
                self.isPresentedCongratulations = true
                self.isAboutToShowCongratulations = false
            }
        }
    }
#endif
    
    private func adjustMantraReads(with value: Int32) {
        let currentReads = mantra.reads
        mantra.reads = value
        handleStatistics(currentReads: currentReads, newReads: value)
        dataManager.saveData()
    }
    
    private func handleStatistics(currentReads: Int32, newReads: Int32) {
        var statistics = mantra.decodedStatistics
        if let currentDateReading = statistics.first(where: { $0.period == Date().startOfDay }), let index = statistics.firstIndex(of: currentDateReading) {
            let newCurrentDateReading = Reading(period: Date().startOfDay, readings: currentDateReading.readings + Int(newReads - currentReads))
            statistics.remove(at: index)
            statistics.append(newCurrentDateReading)
        } else {
            statistics.append(Reading(period: Date().startOfDay, readings: Int(newReads - currentReads)))
        }
        mantra.encodeStatistics(statistics)
    }
    
    private func adjustMantraGoal(with value: Int32) {
        mantra.readsGoal = value
        dataManager.saveData()
    }
    
#if os(watchOS)
    func startMantraCounterSession() {
        session = WKExtendedRuntimeSession()
        session.start()
    }
    
    func endMantraCounterSession() {
        session.invalidate()
    }
#endif
}
