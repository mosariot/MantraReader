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
    @AppStorage("colorScheme", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    private var colorScheme: MantraColorScheme = .system
    var entry: IntentProvider.Entry
    private var preferredColorScheme: ColorScheme? {
        switch colorScheme {
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
        case .systemMedium:
            MediumIntentWidgetView(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
                .environment(\.colorScheme, preferredColorScheme ?? systemColorScheme)
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
