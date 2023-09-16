//
//  MediumStaticWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 21.03.2021.
//

import SwiftUI

struct MediumStaticWidgetView: View {
    var widgetModel: WidgetModel
    
    var body: some View {
        let mantraArray = widgetModel.mantras.prefix(4)
        if mantraArray.count == 0 {
            Image(Constants.defaultImage)
                .resizable()
                .frame(width: 100, height: 100, alignment: .center)
        } else {
            if #available(iOS 17, *) {
                MediumStaticWidgetList(mantraArray: mantraArray)
            } else {
                MediumStaticWidgetList(mantraArray: mantraArray)
                    .padding()
            }
        }
    }
}
