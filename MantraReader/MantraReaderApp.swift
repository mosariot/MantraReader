//
//  MantraReaderApp.swift
//  MantraReader
//
//  Created by Александр Воробьев on 19.06.2022.
//

import SwiftUI

@main
struct MantraReaderApp: App {
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @AppStorage("isFreshLaunch") private var isFreshLaunch = true
    @AppStorage("isPresentedOnboarding") private var isPresentedOnboarding = true
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(OrientationInfo())
                .onAppear {
                    if isFirstLaunch {
                        persistenceController.preloadData(context: persistenceController.container.viewContext)
                        isFirstLaunch = false
                    }
                    isFreshLaunch = true
                }
                .sheet(isPresented: $isPresentedOnboarding) {
                    OnboardingView(isPresented: $isPresentedOnboarding)
                        .interactiveDismissDisabled()
                }
        }
    }
}
