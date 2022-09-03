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
}
