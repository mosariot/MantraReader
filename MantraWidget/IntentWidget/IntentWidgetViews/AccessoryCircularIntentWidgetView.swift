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
            Text("")
        } currentValueLabel: {
            Text("\(formatter.string(fromNumber: (selectedMantra?.reads ?? firstMantra?.reads) ?? 0))")
                .privacySensitive()
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .tint(Color(Constants.progressStartColor))
        .redacted(reason: reasons)
        .widgetURL(URL(string: (selectedMantra?.id.uuidString ?? firstMantra?.id.uuidString) ?? ""))
    }
}
