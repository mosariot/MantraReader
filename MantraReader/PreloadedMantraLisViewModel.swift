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
    let title: String
    let imageString: String
    var isSelected: Bool = false
}

final class PreloadedMantraListViewModel: ObservableObject {
    @Published var mantras: [PreloadedMantra] = preloadedMantras
    @Published var selectedMantrasTitles = Set<String>()
    @Published var isDuplicating = false
    
    private var viewContext: NSManagedObjectContext
    private let addHapticGenerator = UINotificationFeedbackGenerator()
    
    private var preloadedMantras: [PreloadedMantra] {
        var mantras: [PreloadedMantra] = []
        PreloadedMantras.sorted.forEach { data in
            let mantra = PreloadedMantra()
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
    }
    
    init(viewContext: NSManagedObjectContext) {
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
    }
    
    func checkForDuplication(isPresented: Binding<Bool>) {
        if thereIsDuplication() {
            isDuplicating = true
        } else {
            addMantras()
            afterDelay(1.7) { isPresented = false }
        }
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
    
    private func thereIsDuplication() -> {
        false
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
