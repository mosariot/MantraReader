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
        VStack(alignment: .center) {
            ZStack {
                ProgressRing(
                    progress: Double((selectedMantra?.reads ?? firstMantra?.reads) ?? 0) / Double((selectedMantra?.goal ?? firstMantra?.goal) ?? 100000),
                    thickness: 12
                )
                Text("\((selectedMantra?.reads ?? firstMantra?.reads) ?? 0)")
                    .bold()
                    .font(.headline)
                    .privacySensitive()
                    .widgetAccentable()
            }
            .padding(6)
            .padding(.bottom, 1)
            Text((selectedMantra?.title ?? firstMantra?.title) ?? String(localized: "Your mantra"))
                .bold()
                .font(.footnote)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .padding(.top, 1)
                .widgetAccentable()
        }
        .redacted(reason: reasons)
        .widgetURL(URL(string: (selectedMantra?.id.uuidString ?? firstMantra?.id.uuidString ) ?? ""))
    }
}
