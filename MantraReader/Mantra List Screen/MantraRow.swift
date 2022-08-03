//
//  MantraRow.swift
//  MantraReader
//
//  Created by Александр Воробьев on 28.06.2022.
//

import SwiftUI

struct MantraRow: View {
    @ObservedObject var mantra: Mantra
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Image(uiImage: image(for: mantra))
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: CGFloat(Constants.rowHeight))
            VStack(alignment: .leading) {
                Text(mantra.title ?? "")
                Text("Current reads: \(mantra.reads)")
                    .font(.caption)
                    .opacity(isSelected ? 1 : 0.5)
            }
            Spacer()
            if mantra.reads >= mantra.readsGoal {
                Image(systemName: "checkmark")
                .symbolVariant(.circle.fill)
                    .foregroundColor(.green)
            }
        }
    }
    
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
}

struct MantraRow_Previews: PreviewProvider {
    static var previews: some View {
        MantraRow(
            mantra: PersistenceController.previewMantra,
            isSelected: false
        )
            .previewLayout(.fixed(width: 400, height: 55))
            .padding()
            .previewDisplayName("Mantra Row")
    }
}
