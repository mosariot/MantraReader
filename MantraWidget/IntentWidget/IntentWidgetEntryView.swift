//
//  IntentWidgetEntryView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import SwiftUI

struct IntentWidgetEntryView : View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var systemColorScheme
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
#if os(iOS)
        case .systemSmall:
            if #available(iOS 17, *) {
                SmallIntentWidgetView(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
                    .environmentObject(settings)
                    .containerBackground(for: .widget) {
                        systemColorScheme == .dark ? Color(UIColor.systemGroupedBackground) : Color(UIColor.white)
                    }
            } else {
                SmallIntentWidgetView(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
                    .environmentObject(settings)
                    .padding(10)
                    .background(systemColorScheme == .dark ? Color(UIColor.systemGroupedBackground) : Color(UIColor.white))
            }
        case .systemMedium:
            if #available(iOS 17, *) {
                MediumIntentWidgetView(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
                    .environmentObject(settings)
                    .containerBackground(for: .widget) {
                        systemColorScheme == .dark ? Color(UIColor.systemGroupedBackground) : Color(UIColor.white)
                    }
            } else {
                MediumIntentWidgetView(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
                    .environmentObject(settings)
                    .padding(.vertical, 10)
                    .background(systemColorScheme == .dark ? Color(UIColor.systemGroupedBackground) : Color(UIColor.white))
            }
#elseif os(watchOS)
        case .accessoryCorner:
            AccessoryCornerIntentWidgetView(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
                .environmentObject(settings)
#endif
        case .accessoryCircular:
            AccessoryCircularIntentWidgetView(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
                .environmentObject(settings)
        case .accessoryInline:
            AccessoryInlineIntentWidgetView(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
        case .accessoryRectangular:
            AccessoryRectangularIntentWidgetView(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
                .environmentObject(settings)
        default:
            EmptyView()
        }
    }
}
