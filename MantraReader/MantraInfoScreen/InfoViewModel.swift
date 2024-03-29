//
//  InfoViewModel.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 29.07.2022.
//

import SwiftUI
import CoreData

@MainActor
final class InfoViewModel: ObservableObject {
    @Published var mantra: Mantra
    @Published var title: String
    @Published var text: String
    @Published var round: String
    @Published var description: String
    @Published var imageData: Data?
    
    var image: UIImage {
        if let data = imageData, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: Constants.defaultImage)!
        }
    }
    
    var isDuplicating: Bool {
        dataManager.currentMantrasTitles.contains(title)
    }

    var areThereSomeChanges: Bool {
        if mantra.title != title
            || (mantra.text != text && !(text.trimmingCharacters(in: .whitespaces) == "" && mantra.text == nil))
            || mantra.details != description
            || (mantra.image != imageData) {
            return true
        } else {
            return false
        }
    }
    
    var isCleanMantra: Bool {
        if title.trimmingCharacters(in: .whitespaces) == ""
            && text.trimmingCharacters(in: .whitespaces) == ""
            && description.trimmingCharacters(in: .whitespaces) == ""
            && imageData == nil {
            return true
        } else {
            return false
        }
    }
    
    private var dataManager: DataManager
    
    init(_ mantra: Mantra, dataManager: DataManager) {
        self.mantra = mantra
        self.title = mantra.title ?? ""
        self.text = mantra.text ?? ""
        self.round = "\(mantra.round)"
        self.description = mantra.details ?? ""
        self.imageData = mantra.image
        self.dataManager = dataManager
        if self.mantra.uuid == nil {
            mantra.uuid = UUID()
        }
    }
    
    func saveMantraIfNeeded(withCleanUp: Bool = false) {
        if mantra.title != title { mantra.title = title }
        if mantra.text != text { mantra.text = text }
        if mantra.round != Int32(round) { mantra.round = Int32(round) ?? mantra.round }
        if mantra.details != description { mantra.details = description }
        if mantra.image != imageData {
            mantra.image = imageData
            if imageData != nil {
                mantra.imageForTableView = image.resize(to: CGSize(width: Constants.rowHeight, height: Constants.rowHeight)).pngData()
            } else {
                mantra.imageForTableView = nil
            }
        }
        if withCleanUp {
            dataManager.deleteEmptyMantrasIfNeeded()
        } else {
            dataManager.saveData()
        }
    }
    
    func setDefaultImage() {
        imageData = nil
    }
    
    func handleIncomingImage(_ image: UIImage) {
        let circledImage = image.cropToCircle()
        let resizedCircledImage = circledImage?.resize(to: CGSize(width: 200, height: 200))
        if let processedImageData = resizedCircledImage?.pngData() {
            imageData = processedImageData
        }
    }
    
    func updateFields() {
        title = mantra.title ?? ""
        text = mantra.text ?? ""
        round = "\(mantra.round)"
        description = mantra.details ?? ""
        imageData = mantra.image
    }
}
