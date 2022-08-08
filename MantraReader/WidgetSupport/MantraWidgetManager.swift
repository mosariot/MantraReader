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
        let mantras = Array(allMantras
            .sorted { $0.isFavorite && !$1.isFavorite }
            .sorted { sorting == .title ?
                $0.title! < $1.title! :
                $0.reads > $1.reads }
        )
        let mantrasItems = mantras
            .map { WidgetModel.Item(id: $0.uuid ?? UUID(), title: $0.title ?? "", reads: $0.reads, image: $0.imageForTableView) }
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
