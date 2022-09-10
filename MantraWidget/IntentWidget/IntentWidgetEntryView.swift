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
            SmallIntentWidgetView(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
        case .systemMedium:
            MediumIntentWidgetView(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
        case .accessoryCircular:
            AccessoryCircularIntentWidgetView(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
        case .accessoryInline:
            Text("Mantra: \(entry.selectedMantra?.reads ?? entry.firstMantra?.reads ?? 0)")
                .widgetURL(URL(string: "\(entry.selectedMantra?.id ?? entry.firstMantra?.id ?? UUID())"))
        case .accessoryRectangular:
            AccessoryRectangularIntentWidgetVIew(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
        default:
            EmptyView()
        }
    }
}
