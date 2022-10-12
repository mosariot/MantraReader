//
//  SmallIntentWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import SwiftUI

struct SmallIntentWidgetView: View {
    @Environment(\.redactionReasons) private var reasons
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var settings: Settings
    var selectedMantra: WidgetModel.WidgetMantra?
    var firstMantra: WidgetModel.WidgetMantra?
    
    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? UIColor.systemGroupedBackground : UIColor.white)
                .ignoresSafeArea()
            VStack(alignment: .center) {
                ZStack {
                    ProgressRing(
                        progress: Double((selectedMantra?.reads ?? firstMantra?.reads) ?? 0) / Double((selectedMantra?.goal ?? firstMantra?.goal) ?? 100000),
                        thickness: 12
                    )
                    Text("\((selectedMantra?.reads ?? firstMantra?.reads) ?? 0)")
                        .font(.system(.headline, weight: .bold))
                        .privacySensitive()
                }
                .padding(6)
                .padding(.bottom, 1)
                Text((selectedMantra?.title ?? firstMantra?.title) ?? String(localized: "Your mantra"))
                    .font(.system(.footnote, weight: .bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .padding(.top, 1)
            }
            .padding(10)
            .redacted(reason: reasons)
        }
        .widgetURL(URL(string: (selectedMantra?.id.uuidString ?? firstMantra?.id.uuidString ) ?? ""))
    }
}
