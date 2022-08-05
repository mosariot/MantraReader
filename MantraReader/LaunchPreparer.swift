//
//  LaunchPreparer.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 17.08.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import CloudKit

struct LaunchPreparer {
    let persistenceController: PersistenceController
    let isFirstLaunchUIKitVersion = UserDefaults.standard.bool(forKey: "isFirstLaunch")
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        UserDefaults.standard.register(defaults: ["isFirstLaunch": true])
    }
    
    func firstLaunchChecks() {
        if isFirstLaunchUIKitVersion {
            UserDefaults.standard.set(false, forKey: "isFirstLaunch")
            let networkMonitor = NetworkMonitor()
            networkMonitor.startMonitoring()
            DispatchQueue.main.async {
                if !(networkMonitor.isReachable) {
                    persistenceController.preloadData(context: persistenceController.container.viewContext)
                    UserDefaults.standard.set(true, forKey: "isPreloadedMantrasDueToNoInternet")
                } else {
                    checkForiCloudRecords()
                }
                networkMonitor.stopMonitoring()
            }
        }
    }
    
    private func checkForiCloudRecords() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "CD_Mantra", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        var areThereAnyRecords = false
        
        operation.recordMatchedBlock = { (recordId, result) in
            if case .success(_) = result {
                areThereAnyRecords = true
            }
        }
        
        operation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    if !areThereSomeRecords {
                        // no records in iCloud
                        persistenceController.preloadData(context: persistenceController.container.viewContext)
                    } else {
                        // CloudKit automatically handles loading records from iCloud
                    }
                case .failure(_):
                    // for example user is not logged-in iCloud
                    persistenceController.preloadData(context: persistenceController.container.viewContext)
                }
            }
        }
        CKContainer.default().privateCloudDatabase.add(operation)
    }
}
