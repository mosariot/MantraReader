//
//  PreloadedMantraLisViewModel.swift
//  MantraReader
//
//  Created by Александр Воробьев on 29.07.2022.
//

import SwiftUI

struct PreloadedMantra: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let image: String
    var isSelected: Bool = false
}

final class PreloadedMantraLisViewModel: ObservabledObject {
  @Published var mantras: [PreloadedMantra]
  @Published var selectedMantrasTitles: Set<String>
  
  init() {
    mantras = getPreloadedMantras()
    
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
  
  func addMantras() {
  }
  
  private func getPreloadedMantras() -> [PreloadedMantra] {
        var mantras: [PreloadedMantra] = []
        PreloadedMantras.sortedData().forEach { data in
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
