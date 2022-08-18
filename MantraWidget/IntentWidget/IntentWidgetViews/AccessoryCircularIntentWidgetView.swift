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
    
    var body: some View {
        Gauge(value: selectedMantra?.reads ?? Int32(34568), in: 0...(selectedMantra?.goal ?? Int32(100000))) {
            Text(selectedMantra?.title ?? "Your mantra")
        } currentValueLabel: {
            Text("\(selectedMantra?.reads ?? Int32(34568))")
            .privacySensitive()
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(Color(red: 0.880, green: 0.000, blue: 0.100))
        .redacted(reason: reasons)
        .widgetURL(URL(string: "\(selectedMantra?.id)"))
    }
}
