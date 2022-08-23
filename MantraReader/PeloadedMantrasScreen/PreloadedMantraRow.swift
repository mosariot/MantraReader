//
//  PreloadedMantraRow.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 29.07.2022.
//

import SwiftUI

struct PreloadedMantraRow: View {
    let mantra: PreloadedMantra
    
    var body: some View {
        HStack {
            Image(mantra.imageString)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: CGFloat(Constants.rowHeight/2))
            Text(mantra.title)
                .lineLimit(1)
            Spacer()
            if mantra.isSelected {
                Image(systemName: "checkmark")
                    .symbolVariant(.circle.fill)
                    .foregroundColor(.accentColor)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.accentColor)
            }
        }
    }
}
