//
//  DataManager.swift
//  MantraReaderWatch Watch App
//
//  Created by Александр Воробьев on 24.09.2022.
//

import UIKit
import CoreData

final class DataManager: ObservableObject {
    private(set) var viewContext: NSManagedObjectContext
    private let widgetManager = MantraWidgetManager()
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    var currentMantrasTitles: [String] {
        var currentMantras = [Mantra]()
        let request = NSFetchRequest<Mantra>(entityName: "Mantra")
        do {
            try currentMantras = viewContext.fetch(request)
        } catch {
            print("Error getting data. \(error.localizedDescription)")
        }
        return currentMantras.compactMap { $0.title }
    }
    
    var currentMantras: [Mantra] {
        var mantras = [Mantra]()
        let request = NSFetchRequest<Mantra>(entityName: "Mantra")
        do {
            try mantras = viewContext.fetch(request)
        } catch {
            print("Error getting data. \(error.localizedDescription)")
        }
        return mantras
    }
    
    func delete(_ mantra: Mantra, withSaving: Bool = true) {
        viewContext.delete(mantra)
        if withSaving {
            saveData()
        }
    }
    
    func deleteEmptyMantrasIfNeeded() {
        var mantras = [Mantra]()
        let request = NSFetchRequest<Mantra>(entityName: "Mantra")
        do {
            try mantras = viewContext.fetch(request)
        } catch {
            print("Error getting data. \(error.localizedDescription)")
        }
        mantras
            .filter { $0.title == "" }
            .forEach { mantra in delete(mantra, withSaving: false) }
        saveData()
    }
    
    func refresh() {
        viewContext.refreshAllObjects()
    }
    
    func saveData() {
        widgetManager.updateWidgetData(with: currentMantras)
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        } catch {
            fatalCoreDataError(error)
        }
    }
}
