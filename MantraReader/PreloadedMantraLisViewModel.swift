//
//  PreloadedMantraLisViewModel.swift
//  MantraReader
//
//  Created by Александр Воробьев on 29.07.2022.
//

import SwiftUI
import CoreData

struct PreloadedMantra: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let image: String
    var isSelected: Bool = false
}

final class PreloadedMantraLisViewModel: ObservabledObject {
    @Published var mantras: [PreloadedMantra]
    @Published var selectedMantrasTitles: Set<String>
    
    private var viewContext: NSManagedObjectContext
    private let addHapticGenerator = UINotificationFeedbackGenerator()
  
    init(viewContext: NSManagedObjectContext) {
        mantras = getPreloadedMantras()
        selectedMantrasTitles = Set<String>()
        self.viewContext = viewContext
    }
  
    func select(mantra: PreloadedMantra) {
        if selectedMantrasTitles.contains(mantra.title) {
            if let index = mantras.firstIndex(where: { $0.title == mantra.title }) {
                mantras[index].isSelected = false
            }
            selectedMantrasTitles.remove(mantra.title)
    } else {
        if let index = mantras.firstIndex(where: { $0.title == mantra.title }) {
            mantras[index].isSelected = true
        }
        selectedMantrasTitles.insert(mantra.title)
    }
    
    func addMantras() {
        addMantrasToContext()
        addHapticGenerator.notificationOccurred(.success)
    }
  
    func addMantrasToContext() {
        let selectedMantras = mantras.filter {
            guard let title = $0[.title] else { return false }
            return selectedMantrasTitles.contains(title)
        }
        selectedMantras.forEach { selectedMantra in
            let mantra = Mantra(context: viewContext)
            mantra.uuid = UUID()
            mantra.title = selectedMantra[.title]
            mantra.text = selectedMantra[.text]
            mantra.details = selectedMantra[.details]
            mantra.image = UIImage(named: selectedMantra[.image] ?? Constants.defaultImage)?.pngData()
            mantra.imageForTableView = UIImage(named: selectedMantra[.image] ?? Constants.defaultImage)?
                .resize(to: CGSize(width: Constants.rowHeight,
                                   height: Constants.rowHeight)).pngData()
        }
    }
    
    private func saveContext() {
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        } catch {
            fatalCoreDataError(error)
        }
    }
  
  private func getPreloadedMantras() -> [PreloadedMantra] {
        var mantras: [PreloadedMantra] = []
        PreloadedMantras.sorted.forEach { data in
            let mantra = PreloadedMantra()
            data.forEach { key, value in
                if key == .title {
                    mantra.title = value
                }
                if key == .image {
                    mantra.image = value
                }
            }
            mantras.append(mantra)
        }
        return mantras
    }
}
