//
//  SmallStaticWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 21.03.2021.
//

import SwiftUI

struct SmallStaticWidgetView: View {
    var widgetModel: WidgetModel
    
    var body: some View {
        let mantraArray = widgetModel.mantras.prefix(4)
        if mantraArray.count == 0 {
            Image(Constants.defaultImage)
                .resizable()
                .frame(width: 100, height: 100, alignment: .center)
        } else {
            if #available(iOS 17, *) {
                SmallStaticWidgetList(mantraArray: mantraArray)
            } else {
                SmallStaticWidgetList(mantraArray: mantraArray)
                    .padding()
            }
        }
    }
}
