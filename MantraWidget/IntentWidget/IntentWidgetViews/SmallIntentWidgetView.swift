//
//  SmallIntentWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import SwiftUI

struct SmallIntentWidgetView: View {
    @Environment(\.redactionReasons) private var reasons
    @EnvironmentObject private var settings: Settings
    var selectedMantra: WidgetModel.WidgetMantra?
    var firstMantra: WidgetModel.WidgetMantra?
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            VStack {
                ZStack {
                    PercentageRing(
                        ringWidth: 10,
                        percent: Double((selectedMantra?.reads ?? firstMantra?.reads) ?? 0) / Double((selectedMantra?.goal ?? firstMantra?.goal) ?? 100000) * 100
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
