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
        .configurationDisplayName("Current Mantra")
        .description("Track your curent mantra")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryInline, .accessoryRectangular])
    }
}
