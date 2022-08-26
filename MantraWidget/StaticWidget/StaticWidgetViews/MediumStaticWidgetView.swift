//
//  MediumStaticWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 21.03.2021.
//

import SwiftUI

struct MediumStaticWidgetView: View {
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
                HStack {
                    ForEach(mantraArray, id: \.self) { mantra in
                        Link(destination: URL(string: "\(mantra.id)")!) {
                            VStack {
#if os(iOS)
                                Image(uiImage: image(data: mantra.image))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 55, height: 55, alignment: .center)
#elseif os(macOS)
                                Image(nsImage: image(data: mantra.image))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 55, height: 55, alignment: .center)
#endif
                                Text(mantra.title)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .frame(height: 33)
                                    .font(.system(.footnote, weight: .semibold))
                                Text("\(mantra.reads)")
                                    .font(.system(.caption, weight: .semibold))
                                    .foregroundColor(.secondary)
                                    .privacySensitive()
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .redacted(reason: reasons)
                }
                .padding()
            }
        }
    }
#if os(iOS)
    func image(data: Data?) -> UIImage {
        if let data, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: Constants.defaultImage)!.resize(to: CGSize(width: Constants.rowHeight, height: Constants.rowHeight))
        }
    }
#elseif os(macOS)
    func image(data: Data?) -> NSImage {
        if let data, let image = NSImage(data: data) {
            return image
        } else {
            return NSImage(named: Constants.defaultImage)!.resize(to: CGSize(width: Constants.rowHeight, height: Constants.rowHeight))
        }
    }
#endif
}
