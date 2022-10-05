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

struct AccessoryCornerIntentWidgetView: View {
    @Environment(\.redactionReasons) private var reasons
    @Environment(\.widgetRenderingMode) private var widgetRenderingMode
    @EnvironmentObject private var settings: Settings
    var selectedMantra: WidgetModel.WidgetMantra?
    var firstMantra: WidgetModel.WidgetMantra?
    
    private var lineColor: Color {
        switch settings.ringColor {
            case .dynamic:
            if progress < 0.5 {
                return .progressGreenStart
            } else if progress >= 0.5 && progress < 1.0 {
                return .progressYellowStart
            } else if progress >= 1.0 {
                return .progressRedStart
            } else {
                return .accentColor
            }
            case .red: return .progressRedStart
            case .yellow: return .progressYellowStart
            case .green: return .progressGreenStart
        }
    }
    
    private var progress: Double {
#if os(iOS)
        Double((selectedMantra?.reads ?? firstMantra?.reads) ?? 0) / Double((selectedMantra?.goal ?? firstMantra?.goal) ?? 100000)
#elseif os(watchOS)
        Double(selectedMantra?.reads ?? 56683) / Double(selectedMantra?.goal ?? 100000)
#endif
    }
    
    private var value: Double {
#if os(iOS)
        Double((selectedMantra?.reads ?? firstMantra?.reads) ?? 0)
#elseif os(watchOS)
        Double(selectedMantra?.reads ?? 56683)
#endif
    }
    
    private var endRange: Double {
#if os(iOS)
        Double((selectedMantra?.goal ?? firstMantra?.goal) ?? 100000)
#elseif os(watchOS)
        Double(selectedMantra?.goal ?? 100000)
#endif
    }
    
    private var title: String {
#if os(iOS)
        (selectedMantra?.title ?? firstMantra?.title) ?? String(localized: "Your mantra")
#elseif os(watchOS)
        selectedMantra?.title ?? String(localized: "Your mantra")
#endif
    }
    
    var body: some View {
        Gauge(
            value: value,
            in: 0...endRange
        ) {
            Text("")
        } currentValueLabel: {
            Text("\(Int(value))")
                .privacySensitive()
        }
        .gaugeStyle(.accessoryLinear)
        .tint(widgetRenderingMode == .fullColor ? lineColor : nil)
        .redacted(reason: reasons)
        .widgetURL(URL(string: (selectedMantra?.id.uuidString ?? firstMantra?.id.uuidString) ?? ""))
    }
}

struct AccessoryInlineIntentWidgetView: View {
    @Environment(\.redactionReasons) private var reasons
    var selectedMantra: WidgetModel.WidgetMantra?
    var firstMantra: WidgetModel.WidgetMantra?
    
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
#if os(iOS)
                Text((selectedMantra?.title ?? firstMantra?.title) ?? "Your mantra")
                Text("\(selectedMantra?.reads ?? firstMantra?.reads ?? 0)")
                    .privacySensitive()
#elseif os(watchOS)
                Text("\(selectedMantra?.title ?? "Your mantra")")
                Text("\(selectedMantra?.reads ?? 56683)")
                    .privacySensitive()
#endif

            }
            Text("\(selectedMantra?.reads ?? firstMantra?.reads ?? 0)")
                .privacySensitive()
        }
        .redacted(reason: reasons)
        .widgetURL(URL(string: "\(selectedMantra?.id ?? firstMantra?.id ?? UUID())"))
    }
}
