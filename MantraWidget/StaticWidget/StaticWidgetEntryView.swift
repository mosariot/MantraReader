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
#if os(iOS)
        case .systemSmall:
            if #available(iOS 17, *) {
                SmallStaticWidgetView(widgetModel: entry.widgetModel)
                    .containerBackground(for: .widget) {
                        systemColorScheme == .dark ? Color(UIColor.systemGroupedBackground) : Color(UIColor.white)
                    }
            } else {
                ZStack {
                    Color(systemColorScheme == .dark ? UIColor.systemGroupedBackground : UIColor.white)
                    SmallStaticWidgetView(widgetModel: entry.widgetModel)
                }
            }
        case .systemMedium:
            if #available(iOS 17, *) {
                MediumStaticWidgetView(widgetModel: entry.widgetModel)
                    .containerBackground(for: .widget) {
                        systemColorScheme == .dark ? Color(UIColor.systemGroupedBackground) : Color(UIColor.white)
                    }
            } else {
                ZStack {
                    Color(systemColorScheme == .dark ? UIColor.systemGroupedBackground : UIColor.white)
                    MediumStaticWidgetView(widgetModel: entry.widgetModel)
                }
            }
        case .systemLarge:
            if #available(iOS 17, *) {
                LargeStaticWidgetView(widgetModel: entry.widgetModel)
                    .containerBackground(for: .widget) {
                        systemColorScheme == .dark ? Color(UIColor.systemGroupedBackground) : Color(UIColor.white)
                    }
            } else {
                ZStack {
                    Color(systemColorScheme == .dark ? UIColor.systemGroupedBackground : UIColor.white)
                    LargeStaticWidgetView(widgetModel: entry.widgetModel)
                }
            }
#elseif os(watchOS)
        case .accessoryCorner:
            Text("\(entry.widgetModel.mantras.map { $0.reads }.reduce(0,+))")
                .privacySensitive()
#endif
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
