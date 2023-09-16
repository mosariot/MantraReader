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
        for _ in 1...2000 {
            readings.append(Reading(period: date(year: Int.random(in: 2022...2023), month: Int.random(in: 1...12), day: Int.random(in: 1...31)), readings: Int.random(in: 0...56)))
        }
        let reads = Array(Set(readings))
        guard let result = try? JSONEncoder().encode(reads) else { return Data() }
        return result
    }
}
