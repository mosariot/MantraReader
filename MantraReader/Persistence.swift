//
//  Persistence.swift
//  MantraReader
//
//  Created by Александр Воробьев on 19.06.2022.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "MantraReader")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension PersistenceController {
    
    var previewMantras: [Mantra] {
        var data = [Mantra]()
        let request = NSFetchRequest<Mantra>(entityName: "Mantra")
        do {
            try data = container.viewContext.fetch(request)
        } catch {
            print("Error getting data. \(error.localizedDescription)")
        }
        return data
    }
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newMantra = Mantra(context: viewContext)
            newMantra.reads = Int32.random(in: 0...1000)
            newMantra.goal = 1000
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
