//
//  IntentWidgetEntryView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import SwiftUI

struct IntentWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var systemColorScheme
    @ObservedObject private var settings = Settings.shared
    var entry: IntentProvider.Entry
    private var preferredColorScheme: ColorScheme? {
        switch settings.colorScheme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }

    var body: some View {
        switch family {
        case .systemSmall:
            SmallIntentWidgetView(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
                .environment(\.colorScheme, preferredColorScheme ?? systemColorScheme)
                .environmentObject(settings)
        case .systemMedium:
            MediumIntentWidgetView(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
                .environment(\.colorScheme, preferredColorScheme ?? systemColorScheme)
                .environmentObject(settings)
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
