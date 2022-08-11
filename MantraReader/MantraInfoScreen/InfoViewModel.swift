//
//  InfoViewModel.swift
//  MantraReader
//
//  Created by Александр Воробьев on 29.07.2022.
//

import SwiftUI

@MainActor
final class InfoViewModel: ObservableObject {
    @Published var mantra: Mantra
    @Published var title: String
    @Published var text: String
    @Published var description: String
    @Published var image: UIImage
    
    private var viewContext: NSManagedObjectContext
    
    init(_ mantra: Mantra, viewContext: NSManagedObjectContext) {
        self.mantra = mantra
        self.title = mantra.title ?? ""
        self.text = mantra.text ?? ""
        self.description = mantra.details ?? ""
        self.image = UIImage {
            if let data = mantra.image, let image = UIImage(data: data) {
                return image
            } else {
                return UIImage(named: Constants.defaultImage)!
            }
        }
        self.viewContext = viewContext
    }
    
    func saveMantra() {
        mantra.title = title
        mantra.text = text
        mantra.details = description
        mantra.image = image.pngData()
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
        image = UIImage {
            if let data = mantra.image, let image = UIImage(data: data) {
                return image
            } else {
                return UIImage(named: Constants.defaultImage)!
            }
        }
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
