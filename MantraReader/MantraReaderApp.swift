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
    @AppStorage("isPreloadedMantrasDueToNoInternet") private var isPreloadedMantrasDueToNoInternet = false
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
                        print("first launch")
                        isFirstLaunch = false
                        let launchPreparer = LaunchPreparer(persistenceController: persistenceController)
                        launchPreparer.firstLaunchPreparations()
                    } else {
                        print("not first launch")
                    }
                    isFreshLaunch = true
                }
                .alert(
                    "No Internet Connection",
                    isPresented: $isPreloadedMantrasDueToNoInternet
                ) {
                    Button("OK") {
                        isPreloadedMantrasDueToNoInternet = false
                    }
                } message: {
                    Text("It seems like there is no internet connection right now. New set of mantras was preloaded. If you were using 'Mantra Reader' previously with enabled iCloud account, your recordings will be added to the list automatically when internet connection will be available (you may need to relaunch the app).")
                }
                .sheet(isPresented: $isPresentedOnboarding) {
                    OnboardingView(isPresented: $isPresentedOnboarding)
                        .interactiveDismissDisabled()
                }
        }
    }
}
