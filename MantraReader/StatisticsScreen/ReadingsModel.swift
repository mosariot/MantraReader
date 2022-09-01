//
//  ReadingsModel.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 29.08.2022.
//

import Foundation

enum ReadingsData {
    static var last540: Data {
        let readings = Array(
            repeating: (period: date(year: 2022, month: Int.random(in: 3...8), day: Int.random(in: 1...30)), readings: Int.random(in: 0...256)),
            count: 540
        )
        .map { Reading(period: $0.period, readings: $0.readings) }
        return try? JSONEncoder().encode(readings) ?? Data()
    }
    
    static let last30Days = [
        (period: date(year: 2022, month: 5, day: 8), readings: 168),
        (period: date(year: 2022, month: 5, day: 9), readings: 117),
        (period: date(year: 2022, month: 5, day: 10), readings: 106),
        (period: date(year: 2022, month: 5, day: 11), readings: 119),
        (period: date(year: 2022, month: 5, day: 12), readings: 109),
        (period: date(year: 2022, month: 5, day: 13), readings: 104),
        (period: date(year: 2022, month: 5, day: 14), readings: 196),
        (period: date(year: 2022, month: 5, day: 15), readings: 172),
        (period: date(year: 2022, month: 5, day: 16), readings: 122),
        (period: date(year: 2022, month: 5, day: 17), readings: 115),
        (period: date(year: 2022, month: 5, day: 18), readings: 138),
        (period: date(year: 2022, month: 5, day: 19), readings: 110),
        (period: date(year: 2022, month: 5, day: 20), readings: 106),
        (period: date(year: 2022, month: 5, day: 21), readings: 187),
        (period: date(year: 2022, month: 5, day: 22), readings: 187),
        (period: date(year: 2022, month: 5, day: 23), readings: 119),
        (period: date(year: 2022, month: 5, day: 24), readings: 160),
        (period: date(year: 2022, month: 5, day: 25), readings: 144),
        (period: date(year: 2022, month: 5, day: 26), readings: 152),
        (period: date(year: 2022, month: 5, day: 27), readings: 148),
        (period: date(year: 2022, month: 5, day: 28), readings: 240),
        (period: date(year: 2022, month: 5, day: 29), readings: 242),
        (period: date(year: 2022, month: 5, day: 30), readings: 173),
        (period: date(year: 2022, month: 5, day: 31), readings: 143),
        (period: date(year: 2022, month: 6, day: 1), readings: 137),
        (period: date(year: 2022, month: 6, day: 2), readings: 123),
        (period: date(year: 2022, month: 6, day: 3), readings: 146),
        (period: date(year: 2022, month: 6, day: 4), readings: 214),
        (period: date(year: 2022, month: 6, day: 5), readings: 250),
        (period: date(year: 2022, month: 6, day: 6), readings: 146)
    ].map { Reading(period: $0.period, readings: $0.readings) }
    
    static let last7Days = [
        (period: date(year: 2022, month: 5, day: 8), readings: 168),
        (period: date(year: 2022, month: 5, day: 9), readings: 117),
        (period: date(year: 2022, month: 5, day: 10), readings: 106),
        (period: date(year: 2022, month: 5, day: 11), readings: 119),
        (period: date(year: 2022, month: 5, day: 12), readings: 109),
        (period: date(year: 2022, month: 5, day: 13), readings: 104),
        (period: date(year: 2022, month: 5, day: 14), readings: 196)
    ].map { Reading(period: $0.period, readings: $0.readings) }
    
    static let last12Months = [
        (period: date(year: 2021, month: 9), readings: 1680),
        (period: date(year: 2021, month: 10), readings: 1170),
        (period: date(year: 2021, month: 11), readings: 1060),
        (period: date(year: 2021, month: 12), readings: 1190),
        (period: date(year: 2022, month: 1), readings: 1090),
        (period: date(year: 2022, month: 2), readings: 1040),
        (period: date(year: 2022, month: 3), readings: 1960),
        (period: date(year: 2022, month: 4), readings: 1720),
        (period: date(year: 2022, month: 5), readings: 1220),
        (period: date(year: 2022, month: 6), readings: 1150),
        (period: date(year: 2022, month: 7), readings: 1380),
        (period: date(year: 2022, month: 8), readings: 1100),
    ].map { Reading(period: $0.period, readings: $0.readings)}
}

struct Reading: Codable {
    let period: Date
    var readings: Int
}
