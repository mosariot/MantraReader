//
//  Persistence.swift
//  MantraReader
//
//  Created by Александр Воробьев on 19.06.2022.
//

import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "MantraReader")
        
         guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        // Enable history tracking and remote notifications
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        if inMemory { container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null") }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            guard let error = error as NSError? else { return }
            fatalError("Failed to load persistent stores: \(error)")
        })
        
        // Pin the viewContext to the current generation token and set it to keep itself up to date with local changes
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        if !inMemory {
            do {
                try container.viewContext.setQueryGenerationFrom(.current)
            } catch {
                fatalError("Failed to pin viewContext to the current generation: \(error)")
            }
        }
    }
    
    func preloadData(context: NSManagedObjectContext) {
        PreloadedMantras.data.forEach { data in
            let mantra = Mantra(context: context)
            mantra.uuid = UUID()
            mantra.reads = Int32.random(in: 0...200_000)
            mantra.isFavorite = Bool.random()
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
                        mantra.imageForTableView = image.resize(to: CGSize(width: Constants.rowHeight, height: Constants.rowHeight)).pngData()
                    }
                }
            }
        }
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

extension PersistenceController {
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        result.preloadData(context: result.container.viewContext)
        return result
    }()
}
