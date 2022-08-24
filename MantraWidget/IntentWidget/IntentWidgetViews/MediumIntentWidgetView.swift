//
//  MediumIntentWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import SwiftUI

struct MediumIntentWidgetView: View {
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
            GeometryReader { geo in
                HStack(alignment: .bottom) {
                    VStack {
#if os(iOS)
                        Image(uiImage: ((selectedMantra?.image != nil ?
                                         UIImage(data: (selectedMantra?.image)!) :
                                            firstMantra?.image != nil ?
                                         UIImage(data: (firstMantra?.image)!) :
                                            UIImage(named: Constants.defaultImage)?.resize(to: CGSize(width: 100, height: 100)))!))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 100, maxHeight: 100, alignment: .center)
#elseif os(macOS)
                        Image(nsImage: ((selectedMantra?.image != nil ?
                                         NSImage(data: (selectedMantra?.image)!) :
                                            firstMantra?.image != nil ?
                                         NSImage(data: (firstMantra?.image)!) :
                                            NSImage(named: Constants.defaultImage)?.resize(to: CGSize(width: 100, height: 100)))!))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 100, maxHeight: 100, alignment: .center)
#endif
                        Text((selectedMantra?.title ?? firstMantra?.title) ?? String(localized: "Your mantra"))
                            .font(.system(.subheadline, weight: .bold))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .layoutPriority(1)
                    }
                    Spacer()
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
                    .frame(maxWidth: geo.size.height)
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 30)
            .redacted(reason: reasons)
        }
        .widgetURL(URL(string: (selectedMantra?.id.uuidString ?? firstMantra?.id.uuidString) ?? ""))
    }
}
