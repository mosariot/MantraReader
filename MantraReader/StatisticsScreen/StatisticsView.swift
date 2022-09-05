//
//  StatisticsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 28.08.2022.
//

import SwiftUI

struct StatisticsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: StatisticsViewModel
    @State private var selectedWeek: Int = 0
    @State private var selectedMonth: Int = 0
    @State private var selectedYear: Int = 0
    @State private var isLoadingStatistics = false
    private var currentWeek: Int { Calendar(identifier: .gregorian).dateComponents([.weekOfYear], from: Date()).weekOfYear! }
    private var currentMonth: Int { Calendar(identifier: .gregorian).dateComponents([.month], from: Date()).month! }
    private var currentYear: Int { Calendar(identifier: .gregorian).dateComponents([.year], from: Date()).year! }
    private var weekHeader: String {
        switch selectedWeek {
        case 0: return String(localized: "Week")
        case 1...currentWeek:
            let weekStart = date(year: currentYear, weekDay: 2, weekOfYear: selectedWeek)
            let weekEnd = Calendar(identifier: .gregorian).date(byAdding: .day, value: 6, to: weekStart)!
            return "\(weekStart.formatted(.dateTime.day().month(.abbreviated))) - \(weekEnd.formatted(.dateTime.day().month(.abbreviated)))"
        default: return String(localized: "Week")
        }
    }
    private var monthHeader: String {
        switch selectedMonth {
        case 0: return String(localized: "Month")
        case 1...currentMonth: return date(year: currentYear, month: selectedMonth).formatted(.dateTime.month(.wide))
        case (currentMonth+1)...12: return date(year: currentYear-1, month: selectedMonth).formatted(.dateTime.month(.wide).year())
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
                Section(weekHeader) {
                    WeekStatisticsView(data: viewModel.weekData, selectedWeek: $selectedWeek, isLoadingStatistics: isLoadingStatistics)
                }
                Section(monthHeader) {
                    MonthStatisticsView(data: viewModel.monthData, selectedMonth: $selectedMonth, isLoadingStatistics: isLoadingStatistics)
                }
                Section(yearHeader) {
                    YearStatisticsView(data: viewModel.yearData, selectedYear: $selectedYear, isLoadingStatistics: isLoadingStatistics)
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
            .onAppear {
                Task {
                    isLoadingStatistics = true
                    await viewModel.getData(week: selectedWeek, month: selectedMonth, year: selectedYear)
                    isLoadingStatistics = false
                }
                viewModel.getNullData()
            }
            .onChange(of: selectedWeek) { newValue in
                Task { await viewModel.getWeekData(week: newValue) }
            }
            .onChange(of: selectedMonth) { newValue in
                Task { await viewModel.getMonthData(month: newValue) }
            }
            .onChange(of: selectedYear) { newValue in
                Task { await viewModel.getYearData(year: newValue) }
            }
        }
    }
}
