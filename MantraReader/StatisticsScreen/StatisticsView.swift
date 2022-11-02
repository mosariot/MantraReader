//
//  StatisticsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 28.08.2022.
//

import SwiftUI

struct StatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isFirstAppearOfStatistics") private var isFirstAppearOfStatistics = true
    @StateObject var viewModel: StatisticsViewModel
    @State private var selectedWeek: Int = 0
    @State private var selectedMonth: Int = 0
    @State private var selectedYear: Int = 0
    @State private var isShowingLoadingStatistics = false
    @State private var isLoadingStatistics = true
    private var weekHeader: String {
#if os(iOS)
        String(localized: "Week")
#elseif os(watchOS)
        String(localized: "Last 7 Days")
#endif
    }
    private var monthHeader: String {
#if os(iOS)
        String(localized: "Month")
#elseif os(watchOS)
        String(localized: "Last 30 Days")
#endif
    }
    private var yearHeader: String {
#if os(iOS)
        String(localized: "Year")
#elseif os(watchOS)
        String(localized: "Last 12 Months")
#endif
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(weekHeader) {
                    WeekStatisticsView(
                        data: viewModel.weekData,
                        selectedWeek: $selectedWeek,
                        isLoadingStatistics: isShowingLoadingStatistics
                    )
                }
                Section(monthHeader) {
                    MonthStatisticsView(
                        data: viewModel.monthData,
                        selectedMonth: $selectedMonth,
                        isLoadingStatistics: isShowingLoadingStatistics
                    )
                }
                Section(yearHeader) {
                    YearStatisticsView(
                        data: viewModel.yearData,
                        selectedYear: $selectedYear,
                        isLoadingStatistics: isShowingLoadingStatistics
                    )
                }
            }
            .navigationTitle(viewModel.navigationTitle)
#if os(iOS)
            .alert("", isPresented: $isFirstAppearOfStatistics) {
                Button("OK") { }
            } message: {
                Text("This is your reading statistics. To view the exact values hold the bar and move in time.")
            }
            .adaptiveListStyle()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        CloseButtonImage()
                    }
                }
            }
#elseif os(watchOS)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        CloseButtonImage()
                    }
                }
            }
#endif
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
}
