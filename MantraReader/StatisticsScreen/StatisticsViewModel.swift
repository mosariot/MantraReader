//
//  StatisticsViewModel.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 31.08.2022.
//

import SwiftUI

class StatisticsViewModel: ObservableObject {
    var dataManager: DataManager
    var mantra: Mantra?
    private var data = ReadingsData.last2000
    
    init(mantra: Mantra? = nil, dataManager: DataManager) {
        self.mantra = mantra
        self.dataManager = dataManager
    }
    
    var navigationTitle: String {
        mantra?.title ?? String(localized: "Overall Statistics")
    }
}
