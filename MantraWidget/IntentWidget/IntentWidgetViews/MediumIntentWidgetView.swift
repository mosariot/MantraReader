//
//  MediumIntentWidgetView.swift
//  MantraWidgetExtension
//
//  Created by Alex Vorobiev on 17.08.2022.
//

import SwiftUI

struct MediumIntentWidgetView: View {
    @Environment(\.redactionReasons) private var reasons
    @EnvironmentObject private var settings: Settings
    var selectedMantra: WidgetModel.WidgetMantra?
    var firstMantra: WidgetModel.WidgetMantra?
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                VStack {
                    if #available(iOS 18, *) {
                        Image(uiImage: image)
                            .resizable()
                            .widgetAccentedRenderingMode(.accentedDesaturated)
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 100, maxHeight: 100, alignment: .center)
                    } else {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 100, maxHeight: 100, alignment: .center)
                    }
                    Text((selectedMantra?.title ?? firstMantra?.title) ?? String(localized: "Your mantra"))
                        .bold()
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .layoutPriority(1)
                        .widgetAccentable()
                }
                Spacer()
                ZStack {
                    ProgressRing(
                        progress: Double((selectedMantra?.reads ?? firstMantra?.reads) ?? 0) / Double((selectedMantra?.goal ?? firstMantra?.goal) ?? 100000),
                        thickness: 12
                    )
                    .frame(maxWidth: geo.size.height)
                    Text("\((selectedMantra?.reads ?? firstMantra?.reads) ?? 0)")
                        .bold()
                        .font(.headline)
                        .privacySensitive()
                        .widgetAccentable()
                }
                .padding(.vertical, 6)
            }
        }
        .padding(.horizontal, 25)
        .redacted(reason: reasons)
        .widgetURL(URL(string: (selectedMantra?.id.uuidString ?? firstMantra?.id.uuidString) ?? ""))
    }
    
    var image: UIImage {
        if let data = selectedMantra?.image, let image = UIImage(data: data) {
            return image
        } else if let data = firstMantra?.image, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: Constants.defaultImage)!.resize(to: CGSize(width: 100, height: 100))
        }
    }
}
