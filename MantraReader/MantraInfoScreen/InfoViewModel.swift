//
//  InfoViewModel.swift
//  MantraReader
//
//  Created by Александр Воробьев on 29.07.2022.
//

import SwiftUI

@MainActor
final class InfoViewModel: ObservableObject {
    @Published var mantra: Mantra
    @Published var title: String
    @Published var text: String
    @Published var description: String
    @Published var image: UIImage
    
    private var viewContext: NSManagedObjectContext
    
    init(_ mantra: Mantra, viewContext: NSManagedObjectContext) {
        self.mantra = mantra
        self.title = mantra.title ?? ""
        self.text = mantra.text ?? ""
        self.description = mantra.details ?? ""
        self.image = UIImage {
            if let data = mantra.image, let image = UIImage(data: data) {
                return image
            } else {
                return UIImage(named: Constants.defaultImage)!
            }
        }
        self.viewContext = viewContext
    }
    
    func saveMantra() {
    }
    
    func deleteNewMantra() {
    }
}
