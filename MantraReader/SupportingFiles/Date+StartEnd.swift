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
        let components = calendar.dateComponents([.year, .month], from: self)
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

    func isMonday() -> Bool {
        let components = Calendar(identifier: .gregorian).dateComponents([.weekday], from: self)
        return components.weekday == 2
    }
}
