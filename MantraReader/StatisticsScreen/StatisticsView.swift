//
//  StatisticsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 28.08.2022.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    @State private var monthHeader = String(localized: "Month")
    @State private var yearHeader = String(localized: "Year")
    var mantra: Mantra?
    
    var body: some View {
        NavigationStack {
            List {
                Section("Week") {
                    WeekStatisticsView()
                }
                Section(monthHeader) {
                    MonthStatisticsView(monthHeader: $monthHeader)
                }
                Section(yearHeader) {
                    YearStatisticsView(yearHeader: $yearHeader)
                }
            }
            .navigationTitle(mantra?.title ?? String(localized: "Overall Statistics"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .symbolVariant(.circle.fill)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                }
            }
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            StatisticsView()
        }
    }
}
