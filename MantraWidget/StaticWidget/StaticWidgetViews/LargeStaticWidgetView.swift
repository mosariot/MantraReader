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
                if #available(iOS 17, *) {
                    LargeStaticWidgetList(mantraArray: mantraArray)
                } else {
                    LargeStaticWidgetList(mantraArray: mantraArray)
                        .padding()
                }
            }
        }
    }
}
