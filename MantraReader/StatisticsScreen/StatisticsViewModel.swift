//
//  StatisticsViewModel.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 31.08.2022.
//

import SwiftUI

@MainActor
final class StatisticsViewModel: ObservableObject {
    private var mantra: Mantra?
    private var dataManager: DataManager
// To be replaced with mantra.statistics
    private var data: Data = ReadingsData.last540
//  
    private var readings: [Reading] {
        try? JSONDecoder().decode([Reading].self, from: data) ?? []
    }
    
    init(mantra: Mantra? = nil, dataManager: DataManager) {
        self.mantra = mantra
        self.dataManager = dataManager
    }
    
    var navigationTitle: String {
        mantra?.title ?? String(localized: "Overall Statistics")
    }
    
    var weekData: [Reading] {
        ReadingsData.last7Days
    }
    
    var monthData: [Reading] {
        ReadingsData.last30Days
    }
    
    var yearData: [Reading] {
        ReadingsData.last12Months
    }
}
