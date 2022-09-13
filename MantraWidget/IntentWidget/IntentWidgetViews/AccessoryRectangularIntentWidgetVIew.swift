//
//  AccessoryRectangularIntentWidgetVIew.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import SwiftUI

struct AccessoryRectangularIntentWidgetVIew: View {
    @Environment(\.redactionReasons) private var reasons
    var selectedMantra: WidgetModel.WidgetMantra?
    var firstMantra: WidgetModel.WidgetMantra?
    
    var body: some View {
        Gauge(
            value: Double((selectedMantra?.reads ?? firstMantra?.reads) ?? 0),
            in: 0...Double((selectedMantra?.goal ?? firstMantra?.goal) ?? 100000)
        ) {
            Text((selectedMantra?.title ?? firstMantra?.title) ?? "Your mantra")
        } currentValueLabel: {
            Text("\((selectedMantra?.reads ?? firstMantra?.reads) ?? 0)")
                .privacySensitive()
        }
        .gaugeStyle(.accessoryLinearCapacity)
        .redacted(reason: reasons)
        .widgetURL(URL(string: (selectedMantra?.id.uuidString ?? firstMantra?.id.uuidString) ?? ""))
    }
}
