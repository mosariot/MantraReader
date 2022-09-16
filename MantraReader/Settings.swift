//
//  Settings.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 16.09.2022.
//

import SwiftUI

@MainActor
final class Settings: ObservableObject {
    @AppStorage("sorting")
    var sorting: Sorting = .title
    
    @AppStorage("ringColor", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    var ringColor: RingColor = .dynamic
    
    @AppStorage("colorScheme", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    var colorScheme: MantraColorScheme = .system
    
    static let shared = Settings()
    private init() { }
}
