//
//  MantraReaderWatchApp.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 20.09.2022.
//

import SwiftUI

@main
struct MantraReaderWatch_Watch_AppApp: App {
    private let dataManager = DataManager(viewContext: PersistenceController.shared.container.viewContext)
    private let persistenceController = PersistenceController.shared
    private let settings = Settings.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataManager.viewContext)
                .environmentObject(dataManager)
                .environmentObject(settings)
        }
    }
}
