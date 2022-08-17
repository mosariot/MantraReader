//
//  Provider.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 16.08.2022.
//

import SwiftUI
import WidgetKit

struct StaticProvider: TimelineProvider {
    @AppStorage("widgetItem", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    private var widgetItemData: Data = Data()
    
    func placeholder(in context: Context) -> StaticWidgetEntry {
        let placeholderMantras = Array(repeating: WidgetModel.WidgetMantra(id: UUID(), title: "Mantra", reads: 40000, goal: 100000, image: nil), count: 6)
        let widgetItem = WidgetModel(mantras: placeholderMantras)
        return StaticWidgetEntry(widgetModel: widgetItem)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (StaticWidgetEntry) -> ()) {
        guard let widgetItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else { return }
        let entry = StaticWidgetEntry(widgetModel: widgetItem)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StaticWidgetEntry>) -> ()) {
        guard let widgetItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else { return }
        let entry = StaticWidgetEntry(widgetModel: widgetItem)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}
