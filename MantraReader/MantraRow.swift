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
                Text(mantra.title!)
                Text("Current reads: \(mantra.reads)")
                    .font(.caption)
                    .opacity(isSelected ? 1 : 0.5)
            }
            Spacer()
            if mantra.reads >= mantra.readsGoal {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
    
    private func image(for mantra: Mantra) -> UIImage {
        if let imageData = mantra.imageForTableView {
            return UIImage(data: imageData)!
        } else {
            return UIImage(named: Constants.defaultImage)!.resize(
                to: CGSize(width: Constants.rowHeight,
                           height: Constants.rowHeight))
        }
    }
}

import CoreData

struct MantraRow_Previews: PreviewProvider {
    static var controller = PersistenceController.preview
    static func previewMantra(viewContext: NSManagedObjectContext) -> Mantra {
        var mantras = [Mantra]()
        let request = NSFetchRequest<Mantra>(entityName: "Mantra")
        do {
            try mantras = viewContext.fetch(request)
        } catch {
            print("Error getting data. \(error.localizedDescription)")
        }
        return mantras[Int.random(in: 0...mantras.count-1)]
    }
    
    static var previews: some View {
        MantraRow(mantra: previewMantra(viewContext: controller.container.viewContext), selectedMantra: previewMantra(viewContext: controller.container.viewContext))
            .previewLayout(.fixed(width: 400, height: 55))
            .padding()
            .previewDisplayName("Mantra Row")
    }
}
