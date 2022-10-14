//
//  DataManager.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 23.08.2022.
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
    
    func preloadData() {
        PreloadedMantras.data.forEach { data in
            let mantra = Mantra(context: viewContext)
            mantra.uuid = UUID()
// !Test preloading data - not for production!
//            mantra.reads = Int32.random(in: 0...200_000)
//            mantra.statistics = ReadingsData.random
//            mantra.isFavorite = Bool.random()
// End of test preloading data
            data.forEach { key, value in
                switch key {
                case .title:
                    mantra.title = value
                case .text:
                    mantra.text = value
                case .details:
                    mantra.details = value
                case .image:
                    if let image = UIImage(named: value) {
                        mantra.image = image.pngData()
                    }
                case .image_list:
                    if let image = UIImage(named: value) {
                        mantra.imageForTableView = image.pngData()
                    }
                }
            }
        }
        saveData()
    }
    
#if os(iOS)
    func addMantras(with selectedMantrasTitles: Set<String>) {
        let selectedMantras = PreloadedMantras.data.filter {
            guard let title = $0[.title] else { return false }
            return selectedMantrasTitles.contains(title)
        }
        selectedMantras.forEach { selectedMantra in
            let mantra = Mantra(context: viewContext)
            mantra.uuid = UUID()
            mantra.title = selectedMantra[.title]
            mantra.text = selectedMantra[.text]
            mantra.details = selectedMantra[.details]
            mantra.image = UIImage(named: selectedMantra[.image] ?? Constants.defaultImageList)?.pngData()
            mantra.imageForTableView = UIImage(named: selectedMantra[.image_list] ?? Constants.defaultImage)?.pngData()
        }
        saveData()
    }
    
    func refresh() {
        viewContext.refreshAllObjects()
    }
#endif
    
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
