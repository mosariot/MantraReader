//
//  LaunchPreparer.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 17.08.2021.
//

import SwiftUI
import CloudKit

struct LaunchPreparer {
    @AppStorage("isPreloadedMantrasDueToNoInternet") private var isPreloadedMantrasDueToNoInternet = false
    @AppStorage("isInitalDataLoading") private var isInitalDataLoading = true
    let dataManager: DataManager
    
    func firstLaunchPreparations() {
        let networkMonitor = NetworkMonitor()
        networkMonitor.startMonitoring()
        DispatchQueue.main.async {
            if !(networkMonitor.isReachable) {
                dataManager.preloadData()
                isPreloadedMantrasDueToNoInternet = true
                isInitalDataLoading = false
            } else {
                checkForiCloudRecords()
            }
            networkMonitor.stopMonitoring()
        }
    }
    
    private func checkForiCloudRecords() {
        let container = CKContainer(identifier: "iCloud.com.mosariot.MantraCounter")
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
                    if !areThereAnyRecords {
                        // no records in iCloud
                        dataManager.preloadData()
                        isInitalDataLoading = false
                    } else {
                        // CloudKit automatically handles loading records from iCloud
                    }
                case .failure(_):
                    // for example, user is not logged-in iCloud (type of error doesn't matter)
                    dataManager.preloadData()
                    isInitalDataLoading = false
                }
            }
        }
        container.privateCloudDatabase.add(operation)
    }
}
