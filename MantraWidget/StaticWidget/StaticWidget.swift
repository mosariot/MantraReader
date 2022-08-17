//
//  StaticWidget.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 19.12.2020.
//  Copyright © 2020 Alex Vorobiev. All rights reserved.
//

import SwiftUI
import WidgetKit

struct StaticWidget: Widget {
    let kind: String = "MantraWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StaticProvider()) { entry in
            StaticWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Mantra Reader")
        .description("Favorites and Your Other Mantras")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryInline, .accessoryRectangular])
    }
}
