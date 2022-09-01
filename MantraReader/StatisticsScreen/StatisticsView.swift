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
    @State private var selectedMonth: Int = 0
    @State private var selectedYear: Int = 0
    private var currentMonth: Int { Calendar(identifier: .gregorian).dateComponents([.month], from: Date()).month! }
    private var currentYear: Int { Calendar(identifier: .gregorian).dateComponents([.year], from: Date()).year! }
    private var monthHeader: String {
            switch selectedMonth {
            case 0: monthHeader = String(localized: "Month")
            case 1...currentMonth: monthHeader = date(year: currentYear, month: newValue).formatted(.dateTime.month(.wide))
            default: monthHeader = String(localized: "Month")
        }
    }
    private var yearHeader: String {
        switch selectedYear {
            case 0: yearHeader = String(localized: "Year")
            case 2022...currentYear: yearHeader = date(year: newValue).formatted(.dateTime.year())
            default: yearHeader = String(localized: "Year")
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Week") {
                    WeekStatisticsView(data: viewModel.weekData)
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
            .onChange(of: selectedMonth) { newValue in
                print("to handle data providing in viewmodel")
            }
            .onChange(of: selectedYear) { newValue in
                print("to handle data providing in viewmodel")
            }
        }
    }
}
