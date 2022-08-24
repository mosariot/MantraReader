//
//  MediumStaticWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 21.03.2021.
//

import SwiftUI

struct MediumStaticWidgetView: View {
    @Environment(\.redactionReasons) private var reasons
    var widgetModel: WidgetModel
    
    var body: some View {
        let mantraArray = widgetModel.mantras.prefix(4)
        ZStack {
#if os(iOS)
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
#elseif os (macOS)
            Color(NSColor.systemGroupedBackground)
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
                                Image(uiImage: ((mantra.image != nil) ?
                                                UIImage(data: mantra.image!) :
                                                    UIImage(named: Constants.defaultImage))!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 55, height: 55, alignment: .center)
#elseif os(macOS)
                                Image(nsImage: ((mantra.image != nil) ?
                                                NSImage(data: mantra.image!) :
                                                    NSImage(named: Constants.defaultImage))!)
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
}
