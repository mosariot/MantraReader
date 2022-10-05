//
//  AccessoryInlineIntentWidgetView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 05.10.2022.
//

import SwiftUI

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
