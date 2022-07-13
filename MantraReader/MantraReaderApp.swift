//
//  MantraReaderApp.swift
//  MantraReader
//
//  Created by Александр Воробьев on 19.06.2022.
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@main
struct MantraReaderApp: App {
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @AppStorage("isFreshLaunch") private var isFreshLaunch = true
    
    init() {
#if os(iOS)
        UIView.appearance(whenContainedInInstancesOf: [UIView.self]).tintColor = Constants.accentColor
#elseif os(macOS)
        NSView.appearance(whenContainedInInstancesOf: [NSView.self]).tintColor = Constants.accentColor
#endif
    }
    
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
        }
    }
}
