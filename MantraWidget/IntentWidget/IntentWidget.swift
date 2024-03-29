//
//  IntentWidget.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import WidgetKit
import SwiftUI

struct IntentWidget: Widget {
    let kind: String = "IntentWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectMantraIntent.self, provider: IntentProvider()) { entry in
            IntentWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Current mantra")
        .description("Track your current mantra")
#if os(iOS)
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryInline, .accessoryRectangular])
#elseif os(watchOS)
        .supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular, .accessoryCorner])
#endif
    }
}
