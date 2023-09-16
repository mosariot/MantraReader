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
                if #available(iOS 17, *) {
                    MediumStaticWidgetList(mantraArray: mantraArray)
                } else {
                    MediumStaticWidgetList(mantraArray: mantraArray)
                        .padding()
                }
            }
        }
    }
}
