//
//  ReadingsModel.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 29.08.2022.
//

import Foundation

enum ReadingsData {
    static let last30Days = [
        (day: date(year: 2022, month: 5, day: 8), readings: 168),
        (day: date(year: 2022, month: 5, day: 9), readings: 117),
        (day: date(year: 2022, month: 5, day: 10), readings: 106),
        (day: date(year: 2022, month: 5, day: 11), readings: 119),
        (day: date(year: 2022, month: 5, day: 12), readings: 109),
        (day: date(year: 2022, month: 5, day: 13), readings: 104),
        (day: date(year: 2022, month: 5, day: 14), readings: 196),
        (day: date(year: 2022, month: 5, day: 15), readings: 172),
        (day: date(year: 2022, month: 5, day: 16), readings: 122),
        (day: date(year: 2022, month: 5, day: 17), readings: 115),
        (day: date(year: 2022, month: 5, day: 18), readings: 138),
        (day: date(year: 2022, month: 5, day: 19), readings: 110),
        (day: date(year: 2022, month: 5, day: 20), readings: 106),
        (day: date(year: 2022, month: 5, day: 21), readings: 187),
        (day: date(year: 2022, month: 5, day: 22), readings: 187),
        (day: date(year: 2022, month: 5, day: 23), readings: 119),
        (day: date(year: 2022, month: 5, day: 24), readings: 160),
        (day: date(year: 2022, month: 5, day: 25), readings: 144),
        (day: date(year: 2022, month: 5, day: 26), readings: 152),
        (day: date(year: 2022, month: 5, day: 27), readings: 148),
        (day: date(year: 2022, month: 5, day: 28), readings: 240),
        (day: date(year: 2022, month: 5, day: 29), readings: 242),
        (day: date(year: 2022, month: 5, day: 30), readings: 173),
        (day: date(year: 2022, month: 5, day: 31), readings: 143),
        (day: date(year: 2022, month: 6, day: 1), readings: 137),
        (day: date(year: 2022, month: 6, day: 2), readings: 123),
        (day: date(year: 2022, month: 6, day: 3), readings: 146),
        (day: date(year: 2022, month: 6, day: 4), readings: 214),
        (day: date(year: 2022, month: 6, day: 5), readings: 250),
        (day: date(year: 2022, month: 6, day: 6), readings: 146)
    ].map { Reading(period: $0.day, readings: $0.readings) }
    
    static let last7Days = [
        (day: date(year: 2022, month: 5, day: 8), readings: 168),
        (day: date(year: 2022, month: 5, day: 9), readings: 117),
        (day: date(year: 2022, month: 5, day: 10), readings: 106),
        (day: date(year: 2022, month: 5, day: 11), readings: 119),
        (day: date(year: 2022, month: 5, day: 12), readings: 109),
        (day: date(year: 2022, month: 5, day: 13), readings: 104),
        (day: date(year: 2022, month: 5, day: 14), readings: 196)
    ].map { Reading(period: $0.day, readings: $0.readings) }
    
    static let last12Months = [
        (month: date(year: 2021, month: 9), readings: 1680),
        (month: date(year: 2021, month: 10), readings: 1170),
        (month: date(year: 2021, month: 11), readings: 1060),
        (month: date(year: 2021, month: 12), readings: 1190),
        (month: date(year: 2022, month: 1), readings: 1090),
        (month: date(year: 2022, month: 2), readings: 1040),
        (month: date(year: 2022, month: 3), readings: 1960),
        (month: date(year: 2022, month: 4), readings: 1720),
        (month: date(year: 2022, month: 5), readings: 1220),
        (month: date(year: 2022, month: 6), readings: 1150),
        (month: date(year: 2022, month: 7), readings: 1380),
        (month: date(year: 2022, month: 8), readings: 1100),
    ].map { Reading(period: $0.month, readings: $0.readings)}
}

struct Reading {
    let period: Date
    var readings: Int
}
