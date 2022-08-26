//
//  MediumIntentWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import SwiftUI

struct MediumIntentWidgetView: View {
    @Environment(\.redactionReasons) private var reasons
    @Environment(\.colorScheme) var colorScheme
    var selectedMantra: WidgetModel.WidgetMantra?
    var firstMantra: WidgetModel.WidgetMantra?
    
    var body: some View {
        ZStack {
#if os(iOS)
            Color(colorScheme == .dark ? UIColor.systemGroupedBackground : UIColor.white)
                .ignoresSafeArea()
#elseif os (macOS)
            Color(colorScheme == .dark ? NSColor.systemGroupedBackground : NSColor.white)
                .ignoresSafeArea()
#endif
            GeometryReader { geo in
                HStack(alignment: .bottom) {
                    VStack {
#if os(iOS)
                        Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 100, maxHeight: 100, alignment: .center)
#elseif os(macOS)
                        Image(nsImage: image)
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
#if os(iOS)
    var image: UIImage {
        if let data = selectedMantra?.image, let image = UIImage(data: data) {
            return image
        } else if let data = firstMantra?.image, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: Constants.defaultImage)!.resize(to: CGSize(width: 100, height: 100))
        }
    }
#elseif os(macOS)
    var image: NSImage {
        if let data = selectedMantra?.image, let image = NSImage(data: data) {
            return image
        } else if let data = firstMantra?.image, let image = NSImage(data: data) {
            return image
        } else {
            return NSImage(named: Constants.defaultImage)!.resize(to: CGSize(width: 100, height: 100))
        }
    }
#endif
}
