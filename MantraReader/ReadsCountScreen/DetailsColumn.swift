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
    @State var isMantraCounterMode = false
    @Binding var isMantraDeleted: Bool
    
    var body: some View {
        if let unwrappedMantra = selectedMantra {
            ReadsView(
                viewModel: ReadsViewModel(unwrappedMantra, dataManager: dataManager),
                isMantraCounterMode: $isMantraCounterMode,
                isMantraDeleted: $isMantraDeleted
            )
            .onChange(of: selectedMantra) { newValue in
                if isMantraCounterMode {
                    withAnimation {
                        isMantraCounterMode = false
                    }
                    UIApplication.shared.isIdleTimerDisabled = false
                }
                if newValue == nil {
                    isMantraDeleted = true
                }
            }
        } else {
            Text("Select a mantra")
                .foregroundColor(.gray)
        }
    }
}
