//
//  AccessoryRectangularStaticWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 16.08.2022.
//

import SwiftUI

struct AccessoryRectangularStaticWidgetView: View {
    @Environment(\.redactionReasons) private var reasons
    var widgetModel: WidgetModel
    
    var body: some View {
        HStack {
            Image(systemName: "book")
                .imageScale(.large)
                .widgetAccentable()
#if os(watchOS)
                .padding()
#endif
            VStack(alignment: .leading) {
                Text("Total Mantras")
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .widgetAccentable()
                Text("\(widgetModel.mantras.map { $0.reads }.reduce(0,+))")
                    .privacySensitive()
            }
            Spacer()
        }
        .redacted(reason: reasons)
    }
}
