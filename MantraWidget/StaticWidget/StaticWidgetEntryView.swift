//
//  StaticWidgetEntryView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 16.08.2022.
//

import SwiftUI

struct StaticWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var systemColorScheme
    @AppStorage("colorScheme", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    private var colorScheme: MantraColorScheme = .system
    var entry: StaticProvider.Entry
    private var preferredColorScheme: ColorScheme? {
        switch colorScheme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }

    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            SmallStaticWidgetView(widgetModel: entry.widgetModel)
                .environment(\.colorScheme, preferredColorScheme ?? systemColorScheme)
        case .systemMedium:
            MediumStaticWidgetView(widgetModel: entry.widgetModel)
                .environment(\.colorScheme, preferredColorScheme ?? systemColorScheme)
        case .systemLarge:
            LargeStaticWidgetView(widgetModel: entry.widgetModel)
                .environment(\.colorScheme, preferredColorScheme ?? systemColorScheme)
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
