//
//  MediumStaticWidgetList.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 16.09.2023.
//

import SwiftUI

struct MediumStaticWidgetList: View {
    @Environment(\.redactionReasons) private var reasons
    let mantraArray: Array<WidgetModel.WidgetMantra>.SubSequence
    
    var body: some View {
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
                            .bold()
                            .font(.footnote)
                        Text("\(mantra.reads)")
                            .bold()
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .privacySensitive()
                    }
                    .frame(maxWidth: .infinity)
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
