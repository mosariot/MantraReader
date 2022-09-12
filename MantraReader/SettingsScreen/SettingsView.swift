//
//  SettingsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 11.09.2022.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("sorting") private var sorting: Sorting = .title
    @AppStorage("colorScheme") private var colorScheme: ColorScheme = .system
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Mantras sorting", selection: $sorting) {
                    Text("Alphabetically").tag(Sorting.title)
                    Text("By readings count").tag(Sorting.reads)
                }
                Picker("Appearance", selection: $colorScheme) {
                    Text("System").tag(ColorScheme.system)
                    Text("Dark").tag(ColorScheme.light)
                    Text("Light").tag(ColorScheme.dark)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
