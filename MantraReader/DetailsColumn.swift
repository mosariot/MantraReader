//
//  DetailsColumn.swift
//  MantraReader
//
//  Created by Александр Воробьев on 21.06.2022.
//

import SwiftUI

struct DetailsColumn: View {
    var selectedMantra: Mantra?
    
    var body: some View {
        ZStack {
            if let selectedMantra {
                ReadsView(viewModel: ReadsViewModel(selectedMantra))
            } else {
                Text("Select a mantra")
                    .foregroundColor(.gray)
            }
        }
    }
}

import CoreData

struct DetailsView_Previews: PreviewProvider {
    static var controller = PersistenceController.preview
    static func previewMantra(viewContext: NSManagedObjectContext) -> Mantra {
        var mantras = [Mantra]()
        let request = NSFetchRequest<Mantra>(entityName: "Mantra")
        do {
            try mantras = viewContext.fetch(request)
        } catch {
            print("Error getting data. \(error.localizedDescription)")
        }
        return mantras.first!
    }
    
    static var previews: some View {
        DetailsColumn(selectedMantra: previewMantra(viewContext: controller.container.viewContext))
    }
}
