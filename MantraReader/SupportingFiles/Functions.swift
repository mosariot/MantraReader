//
//  Functions.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 16.04.2021.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

func date(year: Int? = nil, month: Int? = nil, day: Int? = nil, weekDay: Int? = nil, weekOfYear: Int? = nil) -> Date {
    Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: day, weekday: weekDay, weekOfYear: weekOfYear)) ?? Date()
}

let dataSaveFailedNotification = Notification.Name("DataSaveFailedNotification")
func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error \(error)")
    NotificationCenter.default.post(name: dataSaveFailedNotification, object: nil)
}
