//
//  SettingsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 11.09.2022.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("sorting") private var sorting: Sorting = .title
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Mantras sorting", selection: $sorting) {
                    Text("Alphabetically").tag(Sorting.title)
                    Text("By readings count").tag(Sorting.reads)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
