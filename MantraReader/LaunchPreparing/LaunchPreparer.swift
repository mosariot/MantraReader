//
//  LaunchPreparer.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 17.08.2021.
//

import SwiftUI
import CloudKit

struct LaunchPreparer {
#if os(iOS)
    @AppStorage("isPreloadedMantrasDueToNoInternet") private var isPreloadedMantrasDueToNoInternet = false
#endif
    @AppStorage("isInitalDataLoading") private var isInitalDataLoading = true
    let dataManager: DataManager
    
    func firstLaunchPreparations() {
#if os(iOS)
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
#elseif os(watchOS)
        checkForiCloudRecords()
#endif
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
#if os(iOS)
                        dataManager.preloadData()
#endif
                        isInitalDataLoading = false
                    } else {
                        // CloudKit automatically handles loading records from iCloud
                    }
                case .failure(_):
                    // for example, user is not logged-in iCloud (type of error doesn't matter)
#if os(iOS)
                    dataManager.preloadData()
#endif
                    isInitalDataLoading = false
                }
            }
        }
        container.privateCloudDatabase.add(operation)
    }
}
