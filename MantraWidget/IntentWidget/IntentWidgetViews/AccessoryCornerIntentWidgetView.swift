//
//  AccessoryCornerIntentWidgetView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 05.10.2022.
//

import SwiftUI

struct AccessoryCornerIntentWidgetView: View {
    @Environment(\.redactionReasons) private var reasons
    @Environment(\.widgetRenderingMode) private var widgetRenderingMode
    @EnvironmentObject private var settings: Settings
    var selectedMantra: WidgetModel.WidgetMantra?
    var firstMantra: WidgetModel.WidgetMantra?
    let formatter = KMBFormatter()
    
    private var ringColor: Color {
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
    
    var body: some View {
        EmptyView()
        .widgetLabel {
            Gauge(
                value: Double((selectedMantra?.reads ?? firstMantra?.reads) ?? 0),
                in: 0...Double((selectedMantra?.goal ?? firstMantra?.goal) ?? 100000)
            ) {
                EmptyView()
            } currentValueLabel: {
                Text("\(formatter.string(fromNumber: Int32(value)))")
                    .privacySensitive()
            }
            .gaugeStyle(.accessoryLinearCapacity)
            .tint(widgetRenderingMode == .fullColor ? ringColor : nil)
            .redacted(reason: reasons)
        }
        .widgetURL(URL(string: (selectedMantra?.id.uuidString ?? firstMantra?.id.uuidString) ?? ""))
    }
}

