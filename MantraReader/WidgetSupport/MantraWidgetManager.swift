//
//  MantraWidgetManager.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 19.12.2020.
//

import SwiftUI
import CoreData
import WidgetKit
import ClockKit

struct MantraWidgetManager {
    @AppStorage("widgetItem", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    private var widgetItemData: Data = Data()
    @AppStorage("sorting", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    var sorting: Sorting = .title
    
    func updateWidgetData(with currentMantras: [Mantra]) {
        let widgetModel = getWidgetModel(for: currentMantras)
        storeWidgetItem(widgetModel: widgetModel)
    }
    
    private func getWidgetModel(for allMantras: [Mantra]) -> WidgetModel {
        var sort: [KeyPathComparator<Mantra>]
        switch sorting {
        case .title:
            sort = [KeyPathComparator(\.isFavorite, order: .reverse), KeyPathComparator(\.title, order: .forward)]
        case .reads:
            sort = [KeyPathComparator(\.isFavorite, order: .reverse), KeyPathComparator(\.reads, order: .reverse)]
        }
        let mantras = allMantras.sorted(using: sort)
        let mantrasItems = mantras
            .map { WidgetModel.WidgetMantra(id: $0.uuid ?? UUID(), title: $0.title ?? "", reads: $0.reads, goal: $0.readsGoal, image: imageData(for: $0)) }
        let widgetModel = WidgetModel(mantras: mantrasItems)
        return widgetModel
    }
    
    private func storeWidgetItem(widgetModel: WidgetModel) {
        guard let data = try? JSONEncoder().encode(widgetModel) else { return }
        widgetItemData = data
        WidgetCenter.shared.invalidateConfigurationRecommendations()
        WidgetCenter.shared.reloadAllTimelines()
//#if os(watchOS)
//        CLKComplicationServer.sharedInstance().reloadComplicationDescriptors()
//#endif
    }
    
    private func imageData(for mantra: Mantra) -> Data? {
#if os(iOS)
        mantra.imageForTableView
#elseif os(watchOS)
        nil 
#endif
    }
}
