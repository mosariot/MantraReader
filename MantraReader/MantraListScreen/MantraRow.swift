//
//  MantraRow.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 28.06.2022.
//

import SwiftUI

struct MantraRow: View {
    @ObservedObject var mantra: Mantra
    let isSelected: Bool
    
    var body: some View {
        HStack {
#if os(iOS)
            Image(uiImage: image(for: mantra))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: CGFloat(Constants.rowHeight))
#endif
            VStack(alignment: .leading) {
                Text(mantra.title ?? "")
#if os(watchOS)
                    .font(.system(.body, design: .rounded, weight: .bold))
#endif
                Text("Current readings: \(mantra.reads)")
#if os(iOS)
                    .font(.caption)
                    .opacity(isSelected && UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0.5)
#elseif os(watchOS)
                    .font(.system(.caption, design: .rounded))
                    .opacity(0.5)
#endif
            }
            Spacer()
            if mantra.reads >= mantra.readsGoal {
                Image(systemName: "checkmark")
                .symbolVariant(.circle.fill)
                    .foregroundColor(.green)
            }
        }
    }
    
#if os(iOS)
    private func image(for mantra: Mantra) -> UIImage {
        if let data = mantra.imageForTableView, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: Constants.defaultImage)!
                .resize(
                    to: CGSize(width: Constants.rowHeight,
                               height: Constants.rowHeight))
        }
    }
#endif
}
