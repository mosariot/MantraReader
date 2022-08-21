//
//  AccessoryCircularIntentWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import SwiftUI

struct AccessoryCircularIntentWidgetView: View {
    @Environment(\.redactionReasons) private var reasons
    var selectedMantra: WidgetModel.WidgetMantra?
    var firstMantra: WidgetModel.WidgetMantra?
    let formatter = KMBFormatter()
    
    var body: some View {
        Gauge(
            value: Double((selectedMantra?.reads ?? firstMantra?.reads) ?? 0),
            in: 0...Double((selectedMantra?.goal ?? firstMantra?.goal) ?? 100000)
        ) {
            Text((selectedMantra?.title ?? firstMantra?.title) ?? "Your mantra")
        } currentValueLabel: {
//            Text(formatter.string(for: (selectedMantra?.reads ?? firstMantra?.reads) ?? 0) ?? "0")
//                .privacySensitive()
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(Color(red: 0.880, green: 0.000, blue: 0.100))
        .redacted(reason: reasons)
        .widgetURL(URL(string: (selectedMantra?.id.uuidString ?? firstMantra?.id.uuidString) ?? ""))
    }
}
