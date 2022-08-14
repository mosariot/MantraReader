//
//  InfoViewModel.swift
//  MantraReader
//
//  Created by Александр Воробьев on 29.07.2022.
//

import SwiftUI
import CoreData

@MainActor
final class InfoViewModel: ObservableObject {
    @Published var mantra: Mantra
    @Published var title: String
    @Published var text: String
    @Published var description: String
    @Published var imageData: Data?
    
    var image: UIImage {
        if let data = imageData, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: Constants.defaultImage)!
        }
    }
    
    var isDuplicating: Bool {
        currentMantrasTitles.contains(title)
    }

    var areThereSomeChanges: Bool {
        if mantra.title != title
            || (mantra.text != text && !(text.trimmingCharacters(in: .whitespaces) == "" && mantra.text == nil))
            || mantra.details != description
            || (mantra.image != imageData) {
            return true
        } else {
            return false
        }
    }
    
    var isCleanMantra: Bool {
        if title.trimmingCharacters(in: .whitespaces) == ""
            && text.trimmingCharacters(in: .whitespaces) == ""
            && description.trimmingCharacters(in: .whitespaces) == ""
            && imageData == nil {
            return true
        } else {
            return false
        }
    }
    
    private var viewContext: NSManagedObjectContext
    private let widgetManager = MantraWidgetManager()
    
    init(_ mantra: Mantra, viewContext: NSManagedObjectContext) {
        self.mantra = mantra
        self.title = mantra.title ?? ""
        self.text = mantra.text ?? ""
        self.description = mantra.details ?? ""
        self.imageData = mantra.image
        self.viewContext = viewContext
        if self.mantra.uuid == nil {
            mantra.uuid = UUID()
        }
    }
    
    func saveMantraIfNeeded(withCleanUp: Bool = false) {
        if mantra.title != title { mantra.title = title }
        if mantra.text != text { mantra.text = text }
        if mantra.details != description { mantra.details = description }
        if mantra.image != imageData { mantra.image = imageData }
        if withCleanUp {
            deleteEmptyMantras()
        } else {
            saveContext()
        }
    }
    
    func setDefaultImage() {
        imageData = nil
    }
    
    func deleteEmptyMantras() {
        var mantras = [Mantra]()
        let request = NSFetchRequest<Mantra>(entityName: "Mantra")
        do {
            try mantras = viewContext.fetch(request)
        } catch {
            print("Error getting data. \(error.localizedDescription)")
        }
        mantras
            .filter { $0.title == "" }
            .forEach { mantra in viewContext.delete(mantra) }
        saveContext()
    }
    
    func updateFields() {
        title = mantra.title ?? ""
        text = mantra.text ?? ""
        description = mantra.details ?? ""
        imageData = mantra.image
    }
    
    private var currentMantrasTitles: [String] {
        var currentMantras = [Mantra]()
        let request = NSFetchRequest<Mantra>(entityName: "Mantra")
        do {
            try currentMantras = viewContext.fetch(request)
        } catch {
            print("Error getting data. \(error.localizedDescription)")
        }
        return currentMantras.compactMap { $0.title }
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
