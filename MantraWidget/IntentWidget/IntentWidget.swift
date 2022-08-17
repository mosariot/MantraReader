//
//  IntentWidget.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import WidgetKit
import SwiftUI
import Intents

struct IntentProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> IntentWidgetEntry {
        IntentWidgetEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (IntentWidgetEntry) -> ()) {
        let entry = IntentWidgetEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [IntentWidgetEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = IntentWidgetEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct IntentWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct IntentWidgetEntryView : View {
    var entry: IntentProvider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

struct IntentWidget: Widget {
    let kind: String = "IntentWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: IntentProvider()) { entry in
            IntentWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
