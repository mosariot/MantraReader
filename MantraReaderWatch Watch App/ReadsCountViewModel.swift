//
//  ReadsViewModel.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 26.09.2022.
//

import SwiftUI

@MainActor
final class ReadsViewModel: ObservableObject {
    static private var confettiTrigger: Int = 0
    @Published var mantra: Mantra
    @Published var congratulations: Congratulations?
    @Published var isPresentedCongratulations = false
    @Published var isAboutToShowCongratulations = false
    @Published var confettiTrigger: Int = 0
    
    private var dataManager: DataManager
    
    init(_ mantra: Mantra, dataManager: DataManager) {
        self.mantra = mantra
        self.dataManager = dataManager
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
    
    func handleAdjusting(for adjust: AdjustingType?, with value: Int32) {
        guard let adjust else { return }
        switch adjust {
        case .reads:
            checkForCongratulations(with: mantra.reads + value)
            adjustMantraReads(with: mantra.reads + value)
        case .rounds:
            checkForCongratulations(with: mantra.reads + value * 108)
            adjustMantraReads(with: mantra.reads + value * 108)
        case .value:
            checkForCongratulations(with: value)
            adjustMantraReads(with: value)
        case .goal:
            WKInterfaceDevice.current().play(.click)
            adjustMantraGoal(with: value)
        }
    }
    
    private func checkForCongratulations(with value: Int32) {
        if mantra.reads < mantra.readsGoal && value >= mantra.readsGoal {
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
        if mantra.reads < mantra.readsGoal/2 && mantra.readsGoal/2..<mantra.readsGoal ~= value {
            isAboutToShowCongratulations = true
            afterDelay(Constants.animationTime + 0.3) {
                self.congratulations = .half
                self.isPresentedCongratulations = true
                self.isAboutToShowCongratulations = false
            }
        }
        WKInterfaceDevice.current().play(.click)
    }
    
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
}
