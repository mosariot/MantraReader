//
//  StatisticsViewWatch10.swift
//  MantraReaderWatch Watch App
//
//  Created by Александр Воробьев on 10.06.2023.
//

import SwiftUI

@available(watchOS 10, *)
struct StatisticsViewWatch10: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isFirstAppearOfStatistics") private var isFirstAppearOfStatistics = true
    @StateObject var viewModel: StatisticsViewModel
    @State private var selectedWeek: Int = 0
    @State private var selectedMonth: Int = 0
    @State private var selectedYear: Int = 0
    @State private var isShowingLoadingStatistics = false
    @State private var isLoadingStatistics = true
    private var weekHeader: String {
        String(localized: "Week")
    }
    private var monthHeader: String {
        String(localized: "Month")
    }
    private var yearHeader: String {
        String(localized: "Year")
    }
    
    var body: some View {
        TabView {
            WeekStatisticsView(
                data: viewModel.weekData,
                selectedWeek: $selectedWeek,
                isLoadingStatistics: isShowingLoadingStatistics
            )
            .navigationTitle(weekHeader)
            .containerBackground(Color.blue.gradient, for: .tabView)
            MonthStatisticsView(
                data: viewModel.monthData,
                selectedMonth: $selectedMonth,
                isLoadingStatistics: isShowingLoadingStatistics
            )
            .navigationTitle(monthHeader)
            .containerBackground(Color.green.gradient, for: .tabView)
            YearStatisticsView(
                data: viewModel.yearData,
                selectedYear: $selectedYear,
                isLoadingStatistics: isShowingLoadingStatistics
            )
            .navigationTitle(yearHeader)
            .containerBackground(Color.red.gradient, for: .tabView)
        }
        .tabViewStyle(.verticalPage)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
        }
        .onAppear {
            Task {
                try await Task.sleep(nanoseconds: 250000000)
                if isLoadingStatistics {
                    isShowingLoadingStatistics = true
                }
            }
            Task {
                await viewModel.getData(week: selectedWeek, month: selectedMonth, year: selectedYear)
                isLoadingStatistics = false
                isShowingLoadingStatistics = false
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
