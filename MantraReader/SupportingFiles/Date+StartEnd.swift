//
//  Date+StartEnd.swift
//  MantraReader
//
//  Created by Александр Воробьев on 30.08.2022.
//

import Foundation

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var startOfMonth: Date {
        let components = Calendar(identifier: .gregorian).dateComponents([.year, .month], from: self)
        return Calendar(identifier: .gregorian).date(from: components)!
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.nanosecond = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.nanosecond = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    var startOfMonth: Date {
        let components = Calendar(identifier: .gregorian).dateComponents([.year], from: self)
        return Calendar(identifier: .gregorian).date(from: components)!
    }
    
    var endOfYear: Date {
        var components = DateComponents()
        components.year = 1
        components.nanosecond = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfYear)!
    }

    func isMonday() -> Bool {
        let components = Calendar(identifier: .gregorian).dateComponents([.weekday], from: self)
        return components.weekday == 2
    }
}

extension Date: Strideable {
    public func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }

    public func advanced(by n: TimeInterval) -> Date {
        return self + n
    }
}
