//
//  DetailsColumn.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 21.06.2022.
//

import SwiftUI

struct DetailsColumn: View {
    @EnvironmentObject private var dataManager: DataManager
    var selectedMantra: Mantra?
    @State var isMantraCounterMode: Bool = false
    
    var body: some View {
        if let selectedMantra {
            ReadsView(
                viewModel: ReadsViewModel(selectedMantra, dataManager: dataManager),
                isMantraCounterMode: $isMantraCounterMode
            )
            .onChange(of: selectedMantra) { _ in
                if isMantraCounterMode {
                    withAnimation {
                        isMantraCounterMode = false
                    }
                    UIApplication.shared.isIdleTimerDisabled = false
                }
            }
        } else {
            Text("Select a mantra")
                .foregroundColor(.gray)
        }
    }
}
