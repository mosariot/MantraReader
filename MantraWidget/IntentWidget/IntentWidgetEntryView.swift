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
            SmallIntentWidgetView(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
                .environment(\.colorScheme, preferredColorScheme ?? systemColorScheme)
                .environmentObject(settings)
        case .systemMedium:
            MediumIntentWidgetView(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
                .environment(\.colorScheme, preferredColorScheme ?? systemColorScheme)
                .environmentObject(settings)
#endif
        case .accessoryCircular:
            AccessoryCircularIntentWidgetView(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
                .environmentObject(settings)
        case .accessoryInline:
            ViewThatFits(in: .horizontal) {
                HStack {
                    Text("\(entry.selectedMantra?.title ?? entry.firstMantra?.title ?? "")")
                    Text("\(entry.selectedMantra?.reads ?? entry.firstMantra?.reads ?? 0)")
                }
                Text("\(entry.selectedMantra?.reads ?? entry.firstMantra?.reads ?? 0)")
            }
            .widgetURL(URL(string: "\(entry.selectedMantra?.id ?? entry.firstMantra?.id ?? UUID())"))
        case .accessoryRectangular:
            AccessoryRectangularIntentWidgetVIew(selectedMantra: entry.selectedMantra, firstMantra: entry.firstMantra)
                .environmentObject(settings)
        default:
            EmptyView()
        }
    }
}
