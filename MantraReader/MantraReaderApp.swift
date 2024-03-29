//
//  MantraReaderApp.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 19.06.2022.
//

import SwiftUI
import WidgetKit
import IQKeyboardManagerSwift

@main
struct MantraReaderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @AppStorage("isPreloadedMantrasDueToNoInternet") private var isPreloadedMantrasDueToNoInternet = false
    @AppStorage("isFreshLaunch") private var isFreshLaunch = true
    @AppStorage("isOnboarding") private var isOnboarding = true
    
    @State private var isPresentedNoInternetAlert = false
    
    private let dataManager = DataManager(viewContext: PersistenceController.shared.container.viewContext)
    private let actionService = ActionService.shared
    private let settings = Settings.shared
    
    private var preferredColorScheme: UIUserInterfaceStyle {
        switch settings.colorScheme {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataManager.viewContext)
                .environmentObject(dataManager)
                .environmentObject(actionService)
                .environmentObject(settings)
                .onAppear {
                    setPreferredColorScheme()
                    if isFirstLaunch {
                        let launchPreparer = LaunchPreparer(dataManager: dataManager)
                        launchPreparer.firstLaunchPreparations()
                    }
                    isFreshLaunch = true
                    IQKeyboardManager.shared.enable = true
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
                    alertController.addAction(
                        UIAlertAction(title: String(localized: "OK"), style: .cancel) { _ in
                            let exception = NSException(
                                name: NSExceptionName.internalInconsistencyException,
                                reason: "Fatal Core Data error",
                                userInfo: nil
                            )
                            exception.raise()
                        }
                    )
                    alertController.presentGlobally(animated: true, completion: nil)
                }
        }
    }
    
    private func setPreferredColorScheme() {
        let scenes = UIApplication.shared.connectedScenes
        guard let scene = scenes.first as? UIWindowScene else { return }
        scene.keyWindow?.overrideUserInterfaceStyle = preferredColorScheme
    }
}
