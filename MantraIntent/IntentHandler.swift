//
//  IntentHandler.swift
//  MantraIntent
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import Intents
import SwiftUI

class IntentHandler: INExtension, SelectMantraIntentHandling {
    @AppStorage("widgetItem", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    private var widgetItemData: Data = Data()
    
    func provideMantraOptionsCollection(for intent: SelectMantraIntent, with completion: @escaping (INObjectCollection<WidgetIntentMantra>?, Error?) -> Void) {
        guard let widgetItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else { return }
        let mantras: [WidgetIntentMantra] = widgetItem.mantras
            .sorted(using: KeyPathComparator(\.title, order: .forward))
            .map { WidgetIntentMantra(identifier: $0.id.uuidString, display: $0.title) }
        let collection = INObjectCollection(items: mantras)
        completion(collection, nil)
    }
}
