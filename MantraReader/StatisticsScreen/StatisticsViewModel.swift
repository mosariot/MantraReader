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
    private var currentMonth: Int { calendar.dateComponents([.month], from: Date()).month! }
    private var currentYear: Int { calendar.dateComponents([.year], from: Date()).year! }
// To be replaced with mantra.statistics or mantras statistics
    private var data: Data = ReadingsData.last540
//  
    private var readings: [Reading] {
        try? JSONDecoder().decode([Reading].self, from: data) ?? []
    }
    
    init(mantra: Mantra? = nil, dataManager: DataManager) {
        self.mantra = mantra
        self.dataManager = dataManager
    }
    
    var navigationTitle: String {
        mantra?.title ?? String(localized: "Overall Statistics")
    }
    
    var weekData: [Reading] {
        var result = [Reading]()
        let filtered = readings.filter { weekStart...weekEnd.contains($0.period) }
        for day in stride(from: weekStart, to: weekEnd, by: 60*60*24) {
            var dayReadings = 0
            dayReadings += filtered.filter { $0.period == day }.map { $0.readings }.reduce(0, +)
            result.append(Reading(period: day, readings: dayReadings))
        }
        return result
//        ReadingsData.last7Days
    }
    private var weekStart = calendar.date(byAdding: .day, value: -7, to: weekEnd)!
    private var weekEnd = Date().startOfDay
    
    func monthData(_ month: Int): [Reading] {
        var result = [Reading]()
        let monthStart = monthStart(month)
        let monthEnd = monthEnd(month)
        let filtered = readings.filter { monthStart...monthEnd.contains($0.period) }
        for day in stride(from: monthStart, to: monthEnd, by: 60*60*24) {
            var dayReadings = 0
            dayReadings += filtered.filter { $0.period == day }.map { $0.readings }.reduce(0, +)
            result.append(Reading(period: day, readings: dayReadings))
        }
        return result
//        ReadingsData.last30Days
    }
    
    private func monthStart(_ month: Int) -> Date {
        switch month {
            case 0: return calendar.date(byAdding: .day, value: -30, to: Date().startOfDay)!
            case 1...currentMonth: return date(year: currentYear, month: month)
            default: return Date()
        }
    }
    
    private func monthEnd(_ month: Int) -> [Reading] {
        switch month {
            case 0: return Date().startOfDay
            case 1...currentMonth: return date(year: currentYear, month: month).endOfMonth.startOfDay
            default: return Date()
        }
    }
    
    func yearData(_ year: Int): [Reading] {
        var result = [Reading]()
        let yearStart = yearStart(year)
        let yearEnd = yearEnd(year)
        let filtered = readings.filter { yearStart...yearEnd.contains($0.period) }
        for month in 1...12 {
            let monthResult = [Reading]()
            let monthStart = date(year: year, month: month)
            let monthEnd = date(year: year, month: month).endOfMonth.startOfDay
            for day in stride(from: monthStart, to: monthEnd, by: 60*60*24) {
                var dayReadings = 0
                dayReadings += filtered.filter { $0.period == day }.map { $0.readings }.reduce(0, +)
                monthResult.append(Reading(period: day, readings: dayReadings))
            }
            result.append(Reading(period: date(year: year, month: month), readings: monthReadings))
        }
        return result
//        ReadingsData.last12Months
    }
    
    private func yearStart(_ year: Int) -> Date {
        switch year {
            case 0: return date(year: currentYear - 1, month: currentMonth + 1)
            case 2022...currentYear: return date(year: year)
            default: return Date()
        }
    }
    
    private func yearEnd(_ year: Int) -> [Reading] {
        switch year {
            case 0: return date(year: currentYear, month: currentMonth)
            case 2022...currentYear: return date(year: year).endOfYear.startOfDay
            default: return Date()
        }
    }
}
