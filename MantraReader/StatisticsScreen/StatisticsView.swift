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
    @State private var selectedWeek: Int = 0
    @State private var selectedMonth: Int = 0
    @State private var selectedYear: Int = 0
    private var currentMonth: Int { Calendar(identifier: .gregorian).dateComponents([.month], from: Date()).month! }
    private var currentYear: Int { Calendar(identifier: .gregorian).dateComponents([.year], from: Date()).year! }
    private var monthHeader: String {
        switch selectedMonth {
        case 0: return String(localized: "Month")
        case 1...currentMonth: return date(year: currentYear, month: selectedMonth).formatted(.dateTime.month(.wide))
        default: return String(localized: "Month")
        }
    }
    private var yearHeader: String {
        switch selectedYear {
        case 0: return String(localized: "Year")
        case 2022...currentYear: return date(year: selectedYear).formatted(.dateTime.year())
        default: return String(localized: "Year")
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Week") {
                    WeekStatisticsView(data: viewModel.weekData(selectedWeek), selectedWeek: $selectedWeek)
                }
                Section(monthHeader) {
                    MonthStatisticsView(data: viewModel.monthData(selectedMonth), selectedMonth: $selectedMonth)
                        .animation(.easeInOut, value: selectedMonth)
                }
                Section(yearHeader) {
                    YearStatisticsView(data: viewModel.yearData(selectedYear), selectedYear: $selectedYear)
                        .animation(.easeInOut, value: selectedYear)
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
