//
//  MantraReaderWatchApp.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 20.09.2022.
//

import SwiftUI

@main
struct MantraReaderWatch_Watch_AppApp: App {
    private let settings = Settings.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
        }
    }
}
