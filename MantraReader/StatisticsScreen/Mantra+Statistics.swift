//
//  Mantra+Statistics.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 03.09.2022.
//

import Foundation

extension Mantra {
    var decodedStatistics: [Reading] {
        guard let result = try? JSONDecoder().decode([Reading].self, from: ReadingsData.last) else { return [] }
//        guard let result = try? JSONDecoder().decode([Reading].self, from: statistics) else { return [] }
        return result
    }
    
    func encodeStatistics(_ readings: [Reading]) {
        guard let _ = try? JSONEncoder().encode(readings) else { return }
//        guard let result = try? JSONEncoder().encode(readings) else { return }
//        statistics = result
    }
}
