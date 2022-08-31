//
//  StatisticsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 28.08.2022.
//

import SwiftUI

struct StatisticsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: StatisticsViewModel
    @State private var monthHeader = String(localized: "Month")
    @State private var yearHeader = String(localized: "Year")
    
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
            .navigationTitle(viewModel.navigationTitle)
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
