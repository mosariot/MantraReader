//
//  MantraListColumn.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 23.09.2022.
//

import SwiftUI

struct MantraListColumn: View {
    @State private var isPresentedSettingsSheet = false
    
    var mantras: SectionedFetchResults<Bool, Mantra>
    @Binding var selectedMantra: Mantra?
    
    var body: some View {
        List(mantras
//             , selection: $selectedMantra
        ) { section in
            Section(section.id ? "Favorites" : "Mantras") {
                ForEach(section) { mantra in
                    NavigationLink(value: mantra) {
                        MantraRow(mantra: mantra)
                    }
                }
            }
        }
        .navigationTitle("Mantra Reader")
        .toolbar {
            Button {
                isPresentedSettingsSheet = true
               } label: {
                Label("Settings", systemImage: "slider.horizontal.3")
            }
        }
    }
}
