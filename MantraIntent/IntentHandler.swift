//
//  IntentHandler.swift
//  MantraIntent
//
//  Created by Александр Воробьев on 17.08.2022.
//

import Intents
import SwiftUI

class IntentHandler: INExtension, SelectMantraIntentHandling {
    @AppStorage("widgetItem", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    private var widgetItemData: Data = Data()
    
    func provideMantraOptionsCollection(for intent: SelectMantraIntent, with completion: @escaping (INObjectCollection<WidgetIntentMantra>?, Error?) -> Void) {
        guard let widgetItem = try? JSONDecoder().decode(WidgetModel.self, from: widgetItemData) else { return }
        let mantras: [WidgetIntentMantra] = widgetItem.mantras
            .sorted { $0.title < $1.title }
            .map { mantra in
                let widgetIntentMantra = WidgetIntentMantra(identifier: mantra.id.uuidString, display: mantra.title)
                return widgetIntentMantra
            }
        
        let collection = INObjectCollection(items: mantras)
        completion(collection, nil)
    }
}
