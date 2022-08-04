//
//  PreloadedMantraRow.swift
//  MantraReader
//
//  Created by Александр Воробьев on 29.07.2022.
//

import SwiftUI

struct PreloadedMantraRow: View {
    let mantra: PreloadedMantra
    
    var body: some View {
        HStack {
            Image(mantra.imageString)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
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

struct PreloadedMantraRow_Previews: PreviewProvider {
    static var previews: some View {
        PreloadedMantraRow(
            mantra: PreloadedMantra(title: "Avelokitesvara", imageString: "Avalokitesvara", isSelected: true)
        )
    }
}
