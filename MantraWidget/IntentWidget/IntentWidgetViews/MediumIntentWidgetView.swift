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
    var firstMantra: WidgetModel.WidgetMantra?
    
    var body: some View {
        ZStack {
            Color(uiColor: UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Image(uiImage: ((selectedMantra?.image != nil ?
                                     UIImage(data: (selectedMantra?.image)!) :
                                        firstMantra?.image != nil ?
                                     UIImage(data: (firstMantra?.image)!) :
                                        UIImage(named: Constants.defaultImage)?.resize(to: CGSize(width: 70, height: 70)))!))
                    .resizable()
                    .frame(width: 70, height: 70, alignment: .center)
                    Text((selectedMantra?.title ?? firstMantra?.title) ?? String(localized: "Your mantra"))
                        .font(.system(.subheadline, weight: .bold))
                        .lineLimit(2)
                }
                ZStack {
                    PercentageRing(
                        ringWidth: 10, percent: Double((selectedMantra?.reads ?? firstMantra?.reads) ?? 0) / Double((selectedMantra?.goal ?? firstMantra?.goal) ?? 100000) * 100,
                        backgroundColor: .red.opacity(0.2),
                        foregroundColors: [
                            Color("progressStart"),
                            Color("progressEnd")
                        ]
                    )
                    Text("\((selectedMantra?.reads ?? firstMantra?.reads) ?? 0)")
                        .font(.system(.headline, weight: .bold))
                        .privacySensitive()
                }
            }
            .padding()
            .redacted(reason: reasons)
        }
        .widgetURL(URL(string: (selectedMantra?.id.uuidString ?? firstMantra?.id.uuidString) ?? ""))
    }
}
