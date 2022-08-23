//
//  MantraReaderApp.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 19.06.2022.
//

import SwiftUI
#if os(iOS)
import IQKeyboardManagerSwift
#endif

@main
struct MantraReaderApp: App {
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @AppStorage("isPreloadedMantrasDueToNoInternet") private var isPreloadedMantrasDueToNoInternet = false
    @AppStorage("isFreshLaunch") private var isFreshLaunch = true
    @AppStorage("isOnboarding") private var isOnboarding = true
    
    @State private var isPresentedNoInternetAlert = false
    
    private let persistenceController = PersistenceController.shared
    
#if os(iOS)
    private let actionService = ActionService.shared
    private let orientationInfo = OrientationInfo()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
#if os(iOS)
                .environmentObject(actionService)
                .environmentObject(orientationInfo)
#endif
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    if isFirstLaunch {
                        isFirstLaunch = false
                        let launchPreparer = LaunchPreparer(persistenceController: persistenceController)
                        launchPreparer.firstLaunchPreparations()
                    }
                    isFreshLaunch = true
                    persistenceController.deleteEmptyMantrasIfNeeded()
#if os(iOS)
                    IQKeyboardManager.shared.enable = true
#endif
                }
                .onChange(of: isOnboarding) { newValue in
                    if !newValue {
                        if isPreloadedMantrasDueToNoInternet {
                            isPreloadedMantrasDueToNoInternet = false
                            isPresentedNoInternetAlert = true
                        }
                    }
                }
                .alert(
                    "No Internet Connection",
                    isPresented: $isPresentedNoInternetAlert
                ) {
                    Button("OK") { }
                } message: {
                    Text("It seems like there is no internet connection right now. New set of mantras was preloaded. If you were using 'Mantra Reader' previously with enabled iCloud account, your recordings will be added to the list automatically when internet connection will be available (you may need to relaunch the app).")
                }
                .sheet(isPresented: $isOnboarding) {
                    OnboardingView(isPresented: $isOnboarding)
                        .interactiveDismissDisabled()
                }
                .onReceive(NotificationCenter.default.publisher(for: dataSaveFailedNotification)) { _ in
                    let alertController = GlobalAlertController(
                        title: String(localized: "There was a fatal error in the app and it cannot continue. Press OK to terminate the app. Sorry for inconvenience."),
                        message: "",
                        preferredStyle: .alert
                    )
                    alertController.addAction(UIAlertAction(title: String(localized: "OK"), style: .cancel) { _ in
                        let exception = NSException(
                            name: NSExceptionName.internalInconsistencyException,
                            reason: "Fatal Core Data error",
                            userInfo: nil
                        )
                        exception.raise()
                    })
                    alertController.presentGlobally(animated: true, completion: nil)
                }
        }
    }
}
