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
    @Published var image: UIImage
    @Published var isDuplicating = false
    
    var isThereAreSomeChanges: Bool {
        if mantra.title != title
            || mantra.text != text
            || mantra.details != description
            || mantra.image != image.pngData() {
            return true
        } else {
            return false
        }
    }
    var isCleanMantra: Bool {
        if mantra.title.trimmingCharacters(in: .whitespaces) == ""
            && mantra.text == ""
            && mantra.description == ""
            && mantra.image.pngData() == nil {
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
        if let data = mantra.image, let image = UIImage(data: data) {
            self.image = image
        } else {
            self.image = UIImage(named: Constants.defaultImage)!
        }
        self.viewContext = viewContext
    }
    
    func saveMantraIfNeeded() {
        if mantra.title != title { mantra.title = title }
        if mantra.text != text { mantra.text = text }
        if mantra.details != description { mantra.details = description }
        if mantra.image != image.pngData() { mantra.image != image.pngData() }
        saveContext()
    }
    
    func deleteNewMantra() {
        viewContext.delete(mantra)
        saveContext()
    }
    
    func updateUI() {
        title = mantra.title ?? ""
        text = mantra.text ?? ""
        description = mantra.details ?? ""
        if let data = mantra.image, let image = UIImage(data: data) {
            self.image = image
        } else {
            self.image = UIImage(named: Constants.defaultImage)!
        }
    }
    
    func checkForDuplication() {
        var foundADuplication = false
        currentMantrasTitles.forEach { title in
            if selectedMantrasTitles.contains(where: { $0.caseInsensitiveCompare(title) == .orderedSame }) {
                foundADuplication = true
            }
        }
        isDuplicating = foundADuplication
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
