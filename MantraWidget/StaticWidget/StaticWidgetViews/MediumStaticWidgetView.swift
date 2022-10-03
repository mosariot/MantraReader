//
//  MediumStaticWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 21.03.2021.
//

import SwiftUI

struct MediumStaticWidgetView: View {
    @Environment(\.redactionReasons) private var reasons
    @Environment(\.colorScheme) private var colorScheme
    var widgetModel: WidgetModel
    
    var body: some View {
        let mantraArray = widgetModel.mantras.prefix(4)
        ZStack {
            Color(colorScheme == .dark ? UIColor.systemGroupedBackground : UIColor.white)
                .ignoresSafeArea()
            if mantraArray.count == 0 {
                Image(Constants.defaultImage)
                    .resizable()
                    .frame(width: 100, height: 100, alignment: .center)
            } else {
                HStack {
                    ForEach(mantraArray, id: \.self) { mantra in
                        Link(destination: URL(string: "\(mantra.id)")!) {
                            VStack {
                                Image(uiImage: image(data: mantra.image))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 55, height: 55, alignment: .center)
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
    
    func image(data: Data?) -> UIImage {
        if let data, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: Constants.defaultImageList)!
        }
    }
}
