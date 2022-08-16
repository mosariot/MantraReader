//
//  AccessoryRectangularStaticWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Александр Воробьев on 16.08.2022.
//

import SwiftUI

struct AccessoryRectangularStaticWidgetView: View {
    @Environment(\.redactionReasons) var reasons
    var widgetModel: WidgetModel
    
    var body: some View {
        HStack {
            Image(systemName: "book")
                .imageScale(.large)
            VStack(alignment: .leading) {
                Text("Overall mantra readings")
                    .font(.subheadline)
                Text("\(widgetModel.mantras.map { $0.reads }.reduce(0,+))")
                    .privacySensitive()
            }
            Spacer()
        }
        .redacted(reason: reasons)
    }
}
