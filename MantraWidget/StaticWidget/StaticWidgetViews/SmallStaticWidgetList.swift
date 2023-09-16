//
//  SmallStaticWidgetList.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 16.09.2023.
//

import SwiftUI

struct SmallStaticWidgetList: View {
    @Environment(\.redactionReasons) private var reasons
    let mantraArray: Array<WidgetModel.WidgetMantra>.SubSequence
    
    var body: some View {
        VStack {
            ForEach(0 ..< 2, id: \.self) { row in
                HStack {
                    ForEach(0 ..< 2, id: \.self) { column in
                        VStack {
                            if (2 * row + column) < mantraArray.count {
                                Image(uiImage: image(mantra: mantraArray[2 * row + column]))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 43, height: 43, alignment: .center)
                                Text("\(mantraArray[2 * row + column].reads)")
                                    .bold()
                                    .font(.caption2)
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
    }
    
    func image(mantra: WidgetModel.WidgetMantra) -> UIImage {
        if let data = mantra.image, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: Constants.defaultImageList)!
        }
    }
}
