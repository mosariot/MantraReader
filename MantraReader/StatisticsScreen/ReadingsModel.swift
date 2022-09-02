//
//  ReadingsModel.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 29.08.2022.
//

import SwiftUI

struct Reading: Codable, Hashable {
    let period: Date
    var readings: Int
}

enum ReadingsData {
    @AppStorage("last") static var last = random
    
    static var random: Data {
        var readings = [Reading]()
        for _ in 1...5000 {
            readings.append(Reading(period: date(year: Int.random(in: 2021...2022), month: Int.random(in: 1...12), day: Int.random(in: 1...31)), readings: Int.random(in: 0...56)))
        }
        let reads = Array(Set(readings))
        guard let result = try? JSONEncoder().encode(reads) else { return Data() }
        return result
    }
    
    static let last30Days = [
        (period: date(year: 2022, month: 7, day: 31), readings: 168),
        (period: date(year: 2022, month: 8, day: 1), readings: 117),
        (period: date(year: 2022, month: 8, day: 2), readings: 106),
        (period: date(year: 2022, month: 8, day: 3), readings: 119),
        (period: date(year: 2022, month: 8, day: 4), readings: 109),
        (period: date(year: 2022, month: 8, day: 5), readings: 104),
        (period: date(year: 2022, month: 8, day: 6), readings: 196),
        (period: date(year: 2022, month: 8, day: 7), readings: 172),
        (period: date(year: 2022, month: 8, day: 8), readings: 122),
        (period: date(year: 2022, month: 8, day: 9), readings: 115),
        (period: date(year: 2022, month: 8, day: 10), readings: 138),
        (period: date(year: 2022, month: 8, day: 11), readings: 110),
        (period: date(year: 2022, month: 8, day: 12), readings: 106),
        (period: date(year: 2022, month: 8, day: 13), readings: 187),
        (period: date(year: 2022, month: 8, day: 14), readings: 187),
        (period: date(year: 2022, month: 8, day: 15), readings: 119),
        (period: date(year: 2022, month: 8, day: 16), readings: 160),
        (period: date(year: 2022, month: 8, day: 17), readings: 144),
        (period: date(year: 2022, month: 8, day: 18), readings: 152),
        (period: date(year: 2022, month: 8, day: 19), readings: 148),
        (period: date(year: 2022, month: 8, day: 20), readings: 240),
        (period: date(year: 2022, month: 8, day: 21), readings: 242),
        (period: date(year: 2022, month: 8, day: 22), readings: 173),
        (period: date(year: 2022, month: 8, day: 23), readings: 143),
        (period: date(year: 2022, month: 8, day: 24), readings: 137),
        (period: date(year: 2022, month: 8, day: 25), readings: 123),
        (period: date(year: 2022, month: 8, day: 26), readings: 146),
        (period: date(year: 2022, month: 8, day: 27), readings: 214),
        (period: date(year: 2022, month: 8, day: 28), readings: 250),
        (period: date(year: 2022, month: 8, day: 29), readings: 146),
        (period: date(year: 2022, month: 8, day: 30), readings: 125),
        (period: date(year: 2022, month: 8, day: 31), readings: 235),
        (period: date(year: 2022, month: 9, day: 1), readings: 120),
        (period: date(year: 2022, month: 9, day: 2), readings: 54),
        (period: date(year: 2022, month: 9, day: 3), readings: 57),
        (period: date(year: 2022, month: 9, day: 4), readings: 340),
    ].map { Reading(period: $0.period, readings: $0.readings) }
}
