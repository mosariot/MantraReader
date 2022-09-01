//
//  StatisticsViewModel.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 31.08.2022.
//

import SwiftUI

@MainActor
final class StatisticsViewModel: ObservableObject {
    var dataManager: DataManager
    var mantra: Mantra?
    private var data: Data = ReadingsData.last540
    private var readings: [Readings] {
        try? JSONDecoder().decode([Readings].self, from: data) ?? []
    }
    
    init(mantra: Mantra? = nil, dataManager: DataManager) {
        self.mantra = mantra
        self.dataManager = dataManager
    }
    
    var navigationTitle: String {
        mantra?.title ?? String(localized: "Overall Statistics")
    }
    
    var weekData: [Readings] {
        ReadingsData.last7Days
    }
    
    var monthData: [Readings] {
        ReadingsData.last30Days
    }
    
    var yearData: [Readings] {
        ReadingsData.last12Months
    }
}
