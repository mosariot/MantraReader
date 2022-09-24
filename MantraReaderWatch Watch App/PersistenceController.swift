//
//  PersistenceController.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 24.09.2022.
//

import CoreData

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
}
