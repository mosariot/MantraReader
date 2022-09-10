//
//  StaticWidgetEntryView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 16.08.2022.
//

import SwiftUI

struct StaticWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: StaticProvider.Entry
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            SmallStaticWidgetView(widgetModel: entry.widgetModel)
        case .systemMedium:
            MediumStaticWidgetView(widgetModel: entry.widgetModel)
        case .systemLarge:
            LargeStaticWidgetView(widgetModel: entry.widgetModel)
        case .accessoryInline:
            Text("Mantras: \(entry.widgetModel.mantras.map { $0.reads }.reduce(0,+))")
                .privacySensitive()
        case .accessoryRectangular:
            AccessoryRectangularStaticWidgetView(widgetModel: entry.widgetModel)
        default:
            EmptyView()
        }
    }
}
