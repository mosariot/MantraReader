//
//  Mantra+Statistics.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 03.09.2022.
//

import Foundation

extension Mantra {
    func decodeStatistics() -> [Reading] {
        guard let result = try? JSONDecoder().decode([Reading].self, from: ReadingsData.last) else { return [] }
        return result
    }
    
    func encodeStatistics(_ readings: [Reading]) -> Data {
        guard let result = try? JSONEncoder().encode(readings) else { return Data() }
        return result
    }
}
