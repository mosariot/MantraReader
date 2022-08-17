//
//  IntentProvider.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import WidgetKit
import SwiftUI

struct IntentProvider: IntentTimelineProvider {
    @AppStorage("widgetItem", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    private var widgetItemData: Data = Data()
    
    func placeholder(in context: Context) -> IntentWidgetEntry {
        let placeholderMantra = WidgetModel.WidgetMantra(id: UUID(), title: "Mantra", reads: 40000, goal: 100000, image: nil)
        return IntentWidgetEntry(date: Date(), selectedMantra: placeholderMantra, configuration: SelectMantraIntent())
    }

    func getSnapshot(for configuration: SelectMantraIntent, in context: Context, completion: @escaping (IntentWidgetEntry) -> ()) {
        guard let widgetItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else { return }
        let mantra = widgetItem.mantras.first { $0.id.uuidString == configuration.mantra?.identifier }
        let entry = IntentWidgetEntry(date: Date(), selectedMantra: mantra, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: SelectMantraIntent, in context: Context, completion: @escaping (Timeline<IntentWidgetEntry>) -> ()) {
        guard let widgetItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else { return }
        let mantra = widgetItem.mantras.first { $0.id.uuidString == configuration.mantra?.identifier }
        let entry = IntentWidgetEntry(date: Date(), selectedMantra: mantra, configuration: configuration)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}
