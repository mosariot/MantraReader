//
//  PreloadedMantraListViewModel.swift
//  MantraReader
//
//  Created by Александр Воробьев on 29.07.2022.
//

import SwiftUI
import CoreData

struct PreloadedMantra: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var imageString: String
    var isSelected: Bool = false
}

final class PreloadedMantraListViewModel: ObservableObject {
    @Published var mantras: [PreloadedMantra]
    @Published var selectedMantrasTitles = Set<String>()
    @Published var isDuplicating = false
    
    private var viewContext: NSManagedObjectContext
    private let addHapticGenerator = UINotificationFeedbackGenerator()
    
//    private var preloadedMantras: [PreloadedMantra] {
//        var mantras: [PreloadedMantra] = []
//        PreloadedMantras.sorted.forEach { data in
//            var mantra = PreloadedMantra(title: "", imageString: "")
//            data.forEach { key, value in
//                if key == .title {
//                    mantra.title = value
//                }
//                if key == .image {
//                    mantra.imageString = value
//                }
//            }
//            mantras.append(mantra)
//        }
//        return mantras
//    }
    
    init(viewContext: NSManagedObjectContext) {
        self.mantras = {
            var mantras: [PreloadedMantra] = []
            PreloadedMantras.sorted.forEach { data in
                var mantra = PreloadedMantra(title: "", imageString: "")
                data.forEach { key, value in
                    if key == .title {
                        mantra.title = value
                    }
                    if key == .image {
                        mantra.imageString = value
                    }
                }
                mantras.append(mantra)
            }
            return mantras
        }()
        self.viewContext = viewContext
    }
    
    func select(_ mantra: PreloadedMantra) {
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
    }
    
    func checkForDuplication() {
        if thereIsDuplication {
            isDuplicating = true
        } else {
            addMantras()
//            afterDelay(1.7) { isPresented = false }
        }
    }
    
    func addMantras() {
        addMantrasToContext()
        addHapticGenerator.notificationOccurred(.success)
    }
    
    func addMantrasToContext() {
        let selectedMantras = PreloadedMantras.data.filter {
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
    
    private var thereIsDuplication: Bool {
        var thereIsDuplication = false
        currentMantrasTitles.forEach { title in
            if selectedMantrasTitles.contains(where: { $0.caseInsensitiveCompare(title) == .orderedSame }) {
                thereIsDuplication = true
            }
        }
        return thereIsDuplication
    }
    
    private var currentMantrasTitles: [String] {
        var currentMantras = [Mantra]()
        let request = NSFetchRequest<Mantra>(entityName: "Mantra")
        do {
            try currentMantras = viewContext.fetch(request)
        } catch {
            print("Error getting data. \(error.localizedDescription)")
        }
        return currentMantras.compactMap { $0.title }
    }
    
    private func saveContext() {
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        } catch {
            fatalCoreDataError(error)
        }
    }
}
