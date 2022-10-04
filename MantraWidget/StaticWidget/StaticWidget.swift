//
//  StaticWidget.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 19.12.2020.
//

import SwiftUI
import WidgetKit

struct StaticWidget: Widget {
    let kind: String = "StaticWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StaticProvider()) { entry in
            StaticWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Mantra Reader")
        .description("Track your mantras")
#if os(iOS)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryInline, .accessoryRectangular])
#elseif os(watchOS)
        .supportedFamilies([.accessoryInline, .accessoryRectangular, .accessoryCorner])
#endif
    }
}
