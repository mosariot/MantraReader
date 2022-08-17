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
            Text(entry.selectedMantra?.title ?? "Select mantra")
        case .systemMedium:
            Text(entry.selectedMantra?.title ?? "Select mantra")
        case .accessoryCircular:
            Text(entry.selectedMantra?.title ?? "Select mantra")
        case .accessoryInline:
            Text(entry.selectedMantra?.title ?? "Select mantra")
        case .accessoryRectangular:
            Text(entry.selectedMantra?.title ?? "Select mantra")
        default:
            fatalError("Not implemented")
        }
    }
}
