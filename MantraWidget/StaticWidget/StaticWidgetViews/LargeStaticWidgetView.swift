//
//  LargeStaticWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 21.03.2021.
//

import SwiftUI

struct LargeStaticWidgetView: View {
    var widgetModel: WidgetModel
    
    var body: some View {
        let mantraArray = widgetModel.mantras.prefix(6)
        if mantraArray.count == 0 {
            Image(Constants.defaultImage)
        } else {
            if #available(iOS 17, *) {
                LargeStaticWidgetList(mantraArray: mantraArray)
            } else {
                LargeStaticWidgetList(mantraArray: mantraArray)
                    .padding()
            }
        }
    }
}
