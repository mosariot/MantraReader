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
    @AppStorage("widgetItem", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    private var widgetItemData: Data = Data()
    
    func placeholder(in context: Context) -> IntentWidgetEntry {
        let placeholderMantra = WidgetModel.WidgetMantra(id: UUID(), title: "Mantra", reads: 40000, goal: 100000, image: nil)
        return IntentWidgetEntry(date: Date(), mantra: placeholderMantra, configuration: SelectMantraIntent())
    }

    func getSnapshot(for configuration: SelectMantraIntent, in context: Context, completion: @escaping (IntentWidgetEntry) -> ()) {
        guard let widgetItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else { return }
        let mantra = widgetItem.mantras.first { $0.id.uuidString == configuration.mantra?.identifier }
        let entry = IntentWidgetEntry(date: Date(), mantra: mantra, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: SelectMantraIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let widgetItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else { return }
        let mantra = widgetItem.mantras.first { $0.id.uuidString == configuration.mantra?.identifier }
        let entry = IntentWidgetEntry(date: Date(), mantra: mantra, configuration: configuration)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct IntentWidgetEntry: TimelineEntry {
    let date: Date
    let mantra: WidgetModel.WidgetMantra?
    let configuration: SelectMantraIntent
}

struct IntentWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: IntentProvider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            Text(entry.mantra?.title ?? "Select mantra")
        case .systemMedium:
            Text(entry.mantra?.title ?? "Select mantra")
        case .accessoryCircular:
            Text(entry.mantra?.title ?? "Select mantra")
        case .accessoryInline:
            Text(entry.mantra?.title ?? "Select mantra")
        case .accessoryRectangular:
            Text(entry.mantra?.title ?? "Select mantra")
        default:
            fatalError("Not implemented")
        }
    }
}

struct IntentWidget: Widget {
    let kind: String = "IntentWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectMantraIntent.self, provider: IntentProvider()) { entry in
            IntentWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Selected Mantra")
        .description("Track your curent mantra")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}
