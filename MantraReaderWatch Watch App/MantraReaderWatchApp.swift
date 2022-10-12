//
//  MantraReaderWatchApp.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 20.09.2022.
//

import SwiftUI

@main
struct MantraReaderWatch_Watch_AppApp: App {
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @AppStorage("isOnboarding") private var isOnboarding = true
    
    private let dataManager = DataManager(viewContext: PersistenceController.shared.container.viewContext)
    private let settings = Settings.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataManager.viewContext)
                .environmentObject(dataManager)
                .environmentObject(settings)
                .onAppear {
                    if isFirstLaunch {
                        isFirstLaunch = false
                        let launchPreparer = LaunchPreparer(dataManager: dataManager)
                        launchPreparer.firstLaunchPreparations()
                    }
                }
                .alert(
                    "Welcome to the path of Enlightenment!",
                    isPresented: $isOnboarding
                ) {
                    
                } message: {
                    Text(
        """
        Recitation of mantras is a sacrament.
        Approach this issue with all your awareness.
        In order for the practice of reciting the mantra to be correct, one must receive the transmission of the mantra from the teacher. Transmission is essential to maintain the strength of the original source of the mantra. It’s not enough just to read it in a book or on the Internet.
        For this reason, at start application doesn't include the mantra texts themselves (except Vajrasattva). They must be given to you by your spiritual mentor and can be added manually later.
        We wish you deep awarenesses and spiritual growth!
        """
                    )
                }
        }
    }
}
