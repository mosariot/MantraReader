//
//  StatisticsViewModel.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 31.08.2022.
//

import SwiftUI

@MainActor
final class StatisticsViewModel: ObservableObject {
    private var mantra: Mantra?
    private var dataManager: DataManager
    private var calendar = Calendar(identifier: .gregorian)
    private var currentWeek: Int { calendar.dateComponents([.weekOfYear], from: Date()).weekOfYear! }
    private var currentMonth: Int { calendar.dateComponents([.month], from: Date()).month! }
    private var currentYear: Int { calendar.dateComponents([.year], from: Date()).year! }
    
    @Published var weekData = [Reading]()
    @Published var monthData = [Reading]()
    @Published var yearData = [Reading]()
    
    private var readings = [Reading]()
    private var data: [Reading] {
        if let mantra {
            return mantra.decodedStatistics
        } else {
            var readings = [Reading]()
            dataManager.currentMantras.forEach { readings += $0.decodedStatistics }
            return readings
        }
    }
    
    var navigationTitle: String {
        mantra?.title ?? String(localized: "Overall Statistics")
    }
    
    init(mantra: Mantra? = nil, dataManager: DataManager) {
        self.mantra = mantra
        self.dataManager = dataManager
    }
    
    func getNullData() {
        weekData = weekData(0, readings: [])
        monthData = monthData(0, readings: [])
        yearData = yearData(0, readings: [])
    }
    
    func getData(week: Int, month: Int, year: Int) async -> Void {
        async let dataAsync = data
        await readings = dataAsync
        async let asyncWeekData = weekData(week, readings: readings)
        async let asyncMonthData = monthData(month, readings: readings)
        async let asyncYearData = yearData(year, readings: readings)
        await (weekData, monthData, yearData) = (asyncWeekData, asyncMonthData, asyncYearData)
    }
    
    func getWeekData(week: Int) async -> Void {
        async let asyncWeekData = weekData(week, readings: readings)
        await weekData = asyncWeekData
    }
    
    func getMonthData(month: Int) async -> Void {
        async let asyncMonthData = monthData(month, readings: readings)
        await monthData = asyncMonthData
    }
    
    func getYearData(year: Int) async -> Void {
        async let asyncYearData = yearData(year, readings: readings)
        await yearData = asyncYearData
    }
    
    private func weekData(_ week: Int, readings: [Reading]) -> [Reading] {
        var result = [Reading]()
        let weekStart = weekStart(week)
        let weekEnd = weekEnd(week)
        let filtered = readings.filter { (weekStart...weekEnd).contains($0.period) }
        for day in stride(from: weekStart, to: weekEnd, by: 60*60*24) {
            var dayReadings = 0
            dayReadings += filtered.filter { $0.period == day }.map { $0.readings }.reduce(0, +)
            result.append(Reading(period: day, readings: dayReadings))
        }
        return result
    }
    
    private func weekStart(_ week: Int) -> Date {
        switch week {
        case 0: return calendar.date(byAdding: .day, value: -7, to: weekEnd(week))!
        case 1...currentWeek: return date(year: currentYear, weekDay: 2, weekOfYear: week)
        default: return calendar.date(byAdding: .day, value: -7, to: weekEnd(week))!
        } 
    }
        
    private func weekEnd(_ week: Int) -> Date {
        switch week {
        case 0: return calendar.date(byAdding: .day, value: 1, to: Date())!.startOfDay
        case 1...currentWeek: return calendar.date(byAdding: .day, value: 7, to: weekStart(week))!
        default: return calendar.date(byAdding: .day, value: 1, to: Date())!.startOfDay
        }
    }
    
    private func monthData(_ month: Int, readings: [Reading]) -> [Reading] {
        var result = [Reading]()
        let monthStart = monthStart(month)
        let monthEnd = calendar.date(byAdding: .day, value: 1, to: monthEnd(month))!
        let filtered = readings.filter { (monthStart...monthEnd).contains($0.period) }
        for day in stride(from: monthStart, to: monthEnd, by: 60*60*24) {
            var dayReadings = 0
            dayReadings += filtered.filter { $0.period == day }.map { $0.readings }.reduce(0, +)
            result.append(Reading(period: day, readings: dayReadings))
        }
        return result
    }
    
    private func monthStart(_ month: Int) -> Date {
        switch month {
        case 0: return calendar.date(byAdding: .day, value: -30, to: Date().startOfDay)!
        case 1...currentMonth: return date(year: currentYear, month: month)
        case (currentMonth+1)...12: return date(year: currentYear-1, month: month)
        default: return calendar.date(byAdding: .day, value: -30, to: Date().startOfDay)!
        }
    }
    
    private func monthEnd(_ month: Int) -> Date {
        switch month {
        case 0: return Date().startOfDay
        case 1...currentMonth: return date(year: currentYear, month: month).endOfMonth.startOfDay
        case (currentMonth+1)...12: return date(year: currentYear-1, month: month).endOfMonth.startOfDay
        default: return Date().startOfDay
        }
    }
    
    private func yearData(_ year: Int, readings: [Reading]) -> [Reading] {
        var result = [Reading]()
        let yearStart = yearStart(year)
        let yearEnd = yearEnd(year)
        let filtered = readings.filter { (yearStart...yearEnd).contains($0.period) }
        
        switch year {
        case 0:
            for month in (currentMonth+1)...12 {
                let monthStart = monthStart(month)
                let monthEnd = monthEnd(month)
                let monthReadings = filtered.filter { (monthStart...monthEnd).contains($0.period) }.map { $0.readings }.reduce(0, +)
                result.append(Reading(period: date(year: currentYear-1, month: month), readings: monthReadings))
            }
            for month in 1...currentMonth {
                let monthStart = monthStart(month)
                let monthEnd = monthEnd(month)
                let monthReadings = filtered.filter { (monthStart...monthEnd).contains($0.period) }.map { $0.readings }.reduce(0, +)
                result.append(Reading(period: date(year: currentYear, month: month), readings: monthReadings))
            }
            return result
        case 2022...year:
            for month in 1...12 {
                let monthStart = monthStart(month)
                let monthEnd = monthEnd(month)
                let monthReadings = filtered.filter { (monthStart...monthEnd).contains($0.period) }.map { $0.readings }.reduce(0, +)
                result.append(Reading(period: date(year: year, month: month), readings: monthReadings))
            }
            return result
        default:
            return []
        }
    }
    
    private func yearStart(_ year: Int) -> Date {
        switch year {
        case 0: return date(year: currentYear-1, month: currentMonth+1)
        case 2022...currentYear: return date(year: year)
        default: return date(year: currentYear-1, month: currentMonth+1)
        }
    }
    
    private func yearEnd(_ year: Int) -> Date {
        switch year {
        case 0: return date(year: currentYear, month: currentMonth).endOfMonth.startOfDay
        case 2022...currentYear: return date(year: year).endOfYear.startOfDay
        default: return date(year: currentYear, month: currentMonth).endOfMonth.startOfDay
        }
    }
}
