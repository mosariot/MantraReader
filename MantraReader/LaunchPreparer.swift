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
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        registerDefaults()
    }
    
    func firstLaunchChecks() {
        let isFirstLaunchUIKitVersion = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        if isFirstLaunchUIKitVersion {
            let networkMonitor = NetworkMonitor()
            networkMonitor.startMonitoring()
            DispatchQueue.main.async {
                if !(networkMonitor.isReachable) {
                    persistenceController.preloadData(context: persistenceController.container.viewContext)
                    UserDefaults.standard.set(true, forKey: "isPreloadedMantrasDueToNoInternetConnection")
                    UserDefaults.standard.set(false, forKey: "isInitalDataLoading")
                } else {
                    checkForiCloudRecords()
                }
                UserDefaults.standard.set(false, forKey: "isFirstLaunch")
                networkMonitor.stopMonitoring()
            }
        }
    }
    
    private func checkForiCloudRecords() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "CD_Mantra", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        var areThereSomeRecords = false
        
        operation.recordMatchedBlock = { (recordId, result) in
            if case .success(_) = result {
                areThereSomeRecords = true
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
                    print("error")
                    // for example user is not logged-in iCloud
                    persistenceController.preloadData(context: persistenceController.container.viewContext)
                }
            }
        }
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    func registerDefaults() {
        let dictionary = ["isFirstLaunch": true,
                          "isInitalDataLoading": true,
                          "isPreloadedMantrasDueToNoInternetConnection": false]
        UserDefaults.standard.register(defaults: dictionary)
    }
}
