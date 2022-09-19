//
//  LargeStaticWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 21.03.2021.
//

import SwiftUI

struct LargeStaticWidgetView: View {
    @Environment(\.redactionReasons) private var reasons
    @Environment(\.colorScheme) private var colorScheme
    var widgetModel: WidgetModel
    
    var body: some View {
        let mantraArray = widgetModel.mantras.prefix(6)
        ZStack {
            Color(colorScheme == .dark ? UIColor.systemGroupedBackground : UIColor.white)
                .ignoresSafeArea()
            if mantraArray.count == 0 {
                Image(Constants.defaultImage)
            } else {
                VStack {
                    ForEach(mantraArray, id: \.self) { mantra in
                        Link(destination: URL(string: "\(mantra.id)")!) {
                            VStack() {
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(mantra.title)
                                            .font(.system(.footnote, weight: .semibold))
                                            .lineLimit(1)
                                        HStack(spacing: 0) {
                                            Text("Current readings: ")
                                                .font(.system(.footnote, weight: .semibold))
                                                .foregroundColor(.secondary)
                                            Text("\(mantra.reads)")
                                                .font(.system(.footnote, weight: .semibold))
                                                .foregroundColor(.secondary)
                                                .privacySensitive()
                                        }
                                    }
                                    Spacer()
                                    Image(uiImage: image(data: mantra.image))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 41, height: 41, alignment: .center)
                                }
                            }
                        }
                    }
                    .redacted(reason: reasons)
                }
                .padding()
            }
        }
    }
    
    func image(data: Data?) -> UIImage {
        if let data, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: Constants.defaultImage)!.resize(to: CGSize(width: Constants.rowHeight, height: Constants.rowHeight))
        }
    }
}
