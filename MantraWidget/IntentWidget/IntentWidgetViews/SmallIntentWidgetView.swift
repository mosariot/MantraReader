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
    
    var body: some View {
         ZStack {
             Color(uiColor: UIColor.systemGroupedBackground)
                 .ignoresSafeArea()
             VStack {
                 ZStack {
                     PercentageRing(
                         ringWidth: 10, percent: Double(selectedMantra?.reads ?? 34568)/Double(selectedMantra.goal ?? 100000) * 100,
                         backgroundColor: .red.opacity(0.2),
                         foregroundColors: [
                             Color(red: 0.880, green: 0.000, blue: 0.100),
                             Color(red: 1.000, green: 0.200, blue: 0.540)
                         ]
                     )
                     Text("\(selectedMantra?.reads ?? 34568)")
                        .font(.system(.headline, weight: .bold))
                        .privacySensitive()
                 }
                 Text(selectedMantra?.title ?? "Avalokitesvara")
                     .font(.system(.subheadline, weight: .bold))
                     .multilineTextAlignment(.center)
                     .lineLimit(2)
             }
             .redacted(reason: reasons)
         }
        .widgetURL(URL(string: "\(selectedMantra?.id)"))
    }
}
