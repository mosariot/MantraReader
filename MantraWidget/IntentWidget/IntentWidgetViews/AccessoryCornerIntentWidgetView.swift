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
        case .dynamicReverse:
            if progress < 0.5 {
                return .progressRedStart
            } else if progress >= 0.5 && progress < 1.0 {
                return .progressYellowStart
            } else if progress >= 1.0 {
                return .progressGreenStart
            } else {
                return .accentColor
            }
        case .red: return .progressRedStart
        case .yellow: return .progressYellowStart
        case .green: return .progressGreenStart
        }
    }
    
    private var progress: Double {
        Double((selectedMantra?.reads ?? firstMantra?.reads) ?? 0) / Double((selectedMantra?.goal ?? firstMantra?.goal) ?? 100000)
    }
    
    private var value: Double {
        Double((selectedMantra?.reads ?? firstMantra?.reads) ?? 0)
    }
    
    private var endRange: Double {
        Double((selectedMantra?.goal ?? firstMantra?.goal) ?? 100000)
    }
    
    private var title: String {
        (selectedMantra?.title ?? firstMantra?.title) ?? String(localized: "Your mantra")
    }
    
    var body: some View {
        if #available(iOS 17, *), #available(watchOS 10, *) {
            Text("\(selectedMantra?.reads ?? 56683)")
                .widgetCurvesContent()
                .widgetLabel("\(selectedMantra?.title ?? "Your mantra")")
                .privacySensitive()
                .widgetURL(URL(string: (selectedMantra?.id.uuidString ?? firstMantra?.id.uuidString) ?? ""))
        } else {
            EmptyView()
                .widgetLabel {
                    Gauge(
                        value: value,
                        in: 0...endRange
                    ) {
                        EmptyView()
                    } currentValueLabel: {
                        Text(value == 0 ? "0" : "\(value.formatted(.number.precision(.significantDigits(3)).notation(.compactName)))")
                            .privacySensitive()
                    }
                    .gaugeStyle(.accessoryLinearCapacity)
                    .tint(widgetRenderingMode == .fullColor ? ringColor : nil)
                    .redacted(reason: reasons)
                }
                .widgetURL(URL(string: (selectedMantra?.id.uuidString ?? firstMantra?.id.uuidString) ?? ""))
        }
    }
}

