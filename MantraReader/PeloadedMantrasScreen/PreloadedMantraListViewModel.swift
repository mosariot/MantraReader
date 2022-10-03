//
//  PreloadedMantraListViewModel.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 29.07.2022.
//

import SwiftUI
import CoreData

@MainActor
final class PreloadedMantraListViewModel: ObservableObject {
    @Published var mantras: [PreloadedMantra]
    @Published var selectedMantrasTitles = Set<String>()
    @Published var isDuplicating = false
    
    private var dataManager: DataManager
    
    init(dataManager: DataManager) {
        self.mantras = {
            var mantras: [PreloadedMantra] = []
            PreloadedMantras.sorted.forEach { data in
                var mantra = PreloadedMantra()
                data.forEach { key, value in
                    if key == .title {
                        mantra.title = value
                    }
                    if key == .image_list {
                        mantra.imageString = value
                    }
                }
                mantras.append(mantra)
            }
            return mantras
        }()
        self.dataManager = dataManager
    }
    
    func select(_ mantra: PreloadedMantra) {
        if selectedMantrasTitles.contains(mantra.title) {
            if let index = mantras.firstIndex(where: { $0.title == mantra.title }) {
                mantras[index].isSelected = false
            }
            selectedMantrasTitles.remove(mantra.title)
        } else {
            if let index = mantras.firstIndex(where: { $0.title == mantra.title }) {
                mantras[index].isSelected = true
            }
            selectedMantrasTitles.insert(mantra.title)
        }
    }
    
    func checkForDuplication() {
        var foundADuplication = false
        dataManager.currentMantrasTitles.forEach { title in
            if selectedMantrasTitles.contains(where: { $0.caseInsensitiveCompare(title) == .orderedSame }) {
                foundADuplication = true
            }
        }
        isDuplicating = foundADuplication
    }
}
