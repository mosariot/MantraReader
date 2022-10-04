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
    
#if os(watchOS)
    func recommendations() -> [IntentRecommendation<SelectMantraIntent>] {
        guard let widgetItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else {
            let intent = SelectMantraIntent()
            return [IntentRecommendation(intent: intent, description: Text("Please add some mantras on your iPhone or iPad"))]
        }
        return widgetItem.mantras
            .sorted(using: KeyPathComparator(\.title, order: .forward))
            .map { mantra in
                let intentMantra = WidgetIntentMantra(identifier: mantra.id.uuidString, display: mantra.title)
                let intent = SelectMantraIntent()
                intent.mantra = intentMantra
                return IntentRecommendation(intent: intent, description: Text(mantra.title))
            }
    }
#endif
    
    func placeholder(in context: Context) -> IntentWidgetEntry {
        let placeholderMantra = WidgetModel.WidgetMantra(id: UUID(), title: "Your mantra", reads: 0, goal: 100000, image: nil)
        return IntentWidgetEntry(date: Date(), selectedMantra: placeholderMantra, firstMantra: placeholderMantra, configuration: SelectMantraIntent())
    }

    func getSnapshot(for configuration: SelectMantraIntent, in context: Context, completion: @escaping (IntentWidgetEntry) -> ()) {
        guard let widgetItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else { return }
        let mantra = widgetItem.mantras.first { $0.id.uuidString == configuration.mantra?.identifier }
        let firstMantra = widgetItem.mantras.first
        let entry = IntentWidgetEntry(date: Date(), selectedMantra: mantra, firstMantra: firstMantra, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: SelectMantraIntent, in context: Context, completion: @escaping (Timeline<IntentWidgetEntry>) -> ()) {
        guard let widgetItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else { return }
        let mantra = widgetItem.mantras.first { $0.id.uuidString == configuration.mantra?.identifier }
        let firstMantra = widgetItem.mantras.first
        let entry = IntentWidgetEntry(date: Date(), selectedMantra: mantra, firstMantra: firstMantra, configuration: configuration)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}
