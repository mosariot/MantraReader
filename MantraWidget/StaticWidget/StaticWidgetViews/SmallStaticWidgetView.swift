//
//  SmallStaticWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 21.03.2021.
//

import SwiftUI

struct SmallStaticWidgetView: View {
    @Environment(\.redactionReasons) private var reasons
    @Environment(\.colorScheme) var colorScheme
    var widgetModel: WidgetModel
    
    var body: some View {
        let mantraArray = widgetModel.mantras.prefix(4)
        ZStack {
#if os(iOS)
            Color(colorScheme == .dark ? UIColor.systemGroupedBackground : UIColor.white)
                .ignoresSafeArea()
#elseif os (macOS)
            Color(colorScheme == .dark ? NSColor.systemGroupedBackground : NSColor.white)
                .ignoresSafeArea()
#endif
            if mantraArray.count == 0 {
                Image(Constants.defaultImage)
                    .resizable()
                    .frame(width: 100, height: 100, alignment: .center)
            } else {
                VStack {
                    ForEach(0 ..< 2, id: \.self) { row in
                        HStack {
                            ForEach(0 ..< 2, id: \.self) { column in
                                VStack {
                                    if (2 * row + column) < mantraArray.count {
#if os(iOS)
                                        Image(uiImage: image(mantra: mantraArray[2 * row + column]))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 43, height: 43, alignment: .center)
#elseif os(macOS)
                                        Image(nsImage: image(mantra: mantraArray[2 * row + column]))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 43, height: 43, alignment: .center)
#endif
                                        Text("\(mantraArray[2 * row + column].reads)")
                                            .font(.system(.caption2, weight: .bold))
                                            .foregroundColor(.secondary)
                                            .privacySensitive()
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                    .redacted(reason: reasons)
                }
                .padding()
            }
        }
    }
#if os(iOS)
    func image(mantra: WidgetModel.WidgetMantra) -> UIImage {
        if let data = mantra.image, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: Constants.defaultImage)!.resize(to: CGSize(width: Constants.rowHeight, height: Constants.rowHeight))
        }
    }
#elseif os(macOS)
    func image(mantra: WidgetModel.WidgetMantra) -> NSImage {
        if let data = mantra.image, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: Constants.defaultImage)!.resize(to: CGSize(width: Constants.rowHeight, height: Constants.rowHeight))
        }
    }
#endif
}
