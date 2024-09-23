//
//  LargeStaticWidgetList.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 16.09.2023.
//

import SwiftUI

struct LargeStaticWidgetList: View {
    @Environment(\.redactionReasons) private var reasons
    let mantraArray: Array<WidgetModel.WidgetMantra>.SubSequence
    
    var body: some View {
        VStack {
            ForEach(mantraArray, id: \.self) { mantra in
                Link(destination: URL(string: "\(mantra.id)")!) {
                    VStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(mantra.title)
                                    .bold()
                                    .font(.footnote)
                                    .lineLimit(1)
                                    .widgetAccentable()
                                HStack(spacing: 0) {
                                    Text("Current readings: ")
                                        .bold()
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                    Text("\(mantra.reads)")
                                        .bold()
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                        .privacySensitive()
                                        .widgetAccentable()
                                }
                            }
                            Spacer()
                            if #available(iOS 18, *) {
                                Image(uiImage: image(data: mantra.image))
                                    .resizable()
                                    .widgetAccentedRenderingMode(.accentedDesaturated)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 41, height: 41, alignment: .center)
                            } else {
                                Image(uiImage: image(data: mantra.image))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 41, height: 41, alignment: .center)
                            }
                        }
                    }
                }
            }
            .redacted(reason: reasons)
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
