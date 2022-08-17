//
//  MantraWidgetManager.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 19.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import SwiftUI
import CoreData
import WidgetKit

struct MantraWidgetManager {
    @AppStorage("widgetItem", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    private var widgetItemData: Data = Data()
    @AppStorage("sorting") private var sorting: Sorting = .title
    
    func updateWidgetData(viewContext: NSManagedObjectContext) {
        let allMantras = currentMantras(viewContext: viewContext)
        let widgetModel = getWidgetModel(for: allMantras)
        storeWidgetItem(widgetModel: widgetModel)
    }
    
    private func currentMantras(viewContext: NSManagedObjectContext) -> [Mantra] {
        var mantras = [Mantra]()
        let request = NSFetchRequest<Mantra>(entityName: "Mantra")
        do {
            try mantras = viewContext.fetch(request)
        } catch {
            print("Error getting data. \(error.localizedDescription)")
        }
        return mantras
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
            .map { WidgetModel.WidgetMantra(id: $0.uuid ?? UUID(), title: $0.title ?? "", reads: $0.reads, goal: $0.readsGoal, image: $0.imageForTableView) }
        let widgetModel = WidgetModel(mantras: mantrasItems)
        return widgetModel
    }
    
    private func storeWidgetItem(widgetModel: WidgetModel) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(widgetModel) else { return }
        widgetItemData = data
        WidgetCenter.shared.reloadAllTimelines()
    }
}
