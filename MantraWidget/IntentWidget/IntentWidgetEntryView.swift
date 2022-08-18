//
//  IntentWidgetEntryView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import SwiftUI

struct IntentWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: IntentProvider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallIntentWidgetView(selectedMantra: entry.selectedMantra)
        case .systemMedium:
            MediumIntentWidgetView(selectedMantra: entry.selectedMantra)
        case .accessoryCircular:
            AccessoryCircularIntentWidgetView(selectedMantra: entry.selectedMantra)
        case .accessoryInline:
            Text("Mantra: \(entry.selectedMantra?.reads ?? 0)")
                .widgetURL(URL(string: "\(entry.selectedMantra?.id ?? UUID())"))
        case .accessoryRectangular:
            AccessoryRectangularIntentWidgetVIew(selectedMantra: entry.selectedMantra)
        default:
            fatalError("Not implemented")
        }
    }
}
