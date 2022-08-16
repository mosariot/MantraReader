//
//  SmallStaticWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 21.03.2021.
//  Copyright © 2021 Alex Vorobiev. All rights reserved.
//

import SwiftUI

struct SmallStaticWidgetView: View {
    @Environment(\.redactionReasons) var reasons
    var widgetModel: WidgetModel
    
    var body: some View {
        let mantraArray = widgetModel.mantras.prefix(4)
        ZStack {
            Color.init(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
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
                                        Image(uiImage: ((mantraArray[2 * row + column].image != nil) ?
                                                            UIImage(data: mantraArray[2 * row + column].image!) :
                                                            UIImage(named: Constants.defaultImage))!)
                                            .resizable()
                                            .frame(width: 43, height: 43, alignment: .center)
                                        Text("\(mantraArray[2 * row + column].reads)")
                                            .font(.system(.caption2, weight: .bold))
                                            .foregroundColor(.secondary)
                                            .privacySensitive()
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .redacted(reason: reasons)
                        }
                    }
                }
                .padding()
            }
        }
    }
}
