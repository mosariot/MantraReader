//
//  MediumIntentWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import SwiftUI

struct MediumIntentWidgetView: View {
    @Environment(\.redactionReasons) private var reasons
    var selectedMantra: WidgetModel.WidgetMantra?
    
    var body: some View {
        ZStack {
            Color(uiColor: UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Image(uiImage: (((selectedMantra?.image != nil) ?
                                     UIImage(data: (selectedMantra?.image)!) :
                                        UIImage(named: Constants.defaultImage)?.resize(to: CGSize(width: 70, height: 70)))!))
                    .resizable()
                    .frame(width: 70, height: 70, alignment: .center)
                    Text(selectedMantra?.title ?? "Your mantra")
                        .font(.system(.subheadline, weight: .bold))
                        .lineLimit(2)
                }
                ZStack {
                    PercentageRing(
                        ringWidth: 10, percent: Double(selectedMantra?.reads ?? 0) / Double(selectedMantra?.goal ?? 100000) * 100,
                        backgroundColor: .red.opacity(0.2),
                        foregroundColors: [
                            Color(red: 0.880, green: 0.000, blue: 0.100),
                            Color(red: 1.000, green: 0.200, blue: 0.540)
                        ]
                    )
                    Text("\(selectedMantra?.reads ?? 0)")
                        .font(.system(.headline, weight: .bold))
                        .privacySensitive()
                }
            }
            .padding()
            .redacted(reason: reasons)
        }
        .widgetURL(URL(string: selectedMantra?.id.uuidString ?? ""))
    }
}
