//
//  Date+StartEnd.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 30.08.2022.
//

import Foundation

extension Date {
    var startOfDay: Date {
        return Calendar(identifier: .gregorian).startOfDay(for: self)
    }

    var startOfMonth: Date {
        let components = Calendar(identifier: .gregorian).dateComponents([.year, .month], from: self)
        return Calendar(identifier: .gregorian).date(from: components)!
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfDay)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    var startOfYear: Date {
        let components = Calendar(identifier: .gregorian).dateComponents([.year], from: self)
        return Calendar(identifier: .gregorian).date(from: components)!
    }
    
    var endOfYear: Date {
        var components = DateComponents()
        components.year = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfYear)!
    }
}
