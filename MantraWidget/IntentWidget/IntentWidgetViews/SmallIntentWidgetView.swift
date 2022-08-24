//
//  SmallIntentWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import SwiftUI

struct SmallIntentWidgetView: View {
    @Environment(\.redactionReasons) private var reasons
    var selectedMantra: WidgetModel.WidgetMantra?
    var firstMantra: WidgetModel.WidgetMantra?
    
    var body: some View {
        ZStack {
#if os(iOS)
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
#elseif os (macOS)
            Color(NSColor.systemGroupedBackground)
                .ignoresSafeArea()
#endif
            VStack {
                ZStack {
                    PercentageRing(
                        ringWidth: 10,
                        percent: Double((selectedMantra?.reads ?? firstMantra?.reads) ?? 0) / Double((selectedMantra?.goal ?? firstMantra?.goal) ?? 100000) * 100,
                        backgroundColor: .red.opacity(0.2),
                        foregroundColors: [
                            Color(Constants.progressStartColor),
                            Color(Constants.progressEndColor)
                        ]
                    )
                    Text("\((selectedMantra?.reads ?? firstMantra?.reads) ?? 0)")
                        .font(.system(.headline, weight: .bold))
                        .privacySensitive()
                }
                Text((selectedMantra?.title ?? firstMantra?.title) ?? String(localized: "Your mantra"))
                    .font(.system(.footnote, weight: .bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .padding(.top, 1)
            }
            .padding()
            .redacted(reason: reasons)
        }
        .widgetURL(URL(string: (selectedMantra?.id.uuidString ?? firstMantra?.id.uuidString ) ?? ""))
    }
}
