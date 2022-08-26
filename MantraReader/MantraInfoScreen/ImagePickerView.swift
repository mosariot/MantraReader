//
//  ImagePickerView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 21.08.2022.
//

import PhotosUI
import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isProcessingImage: Bool
    @Binding var isPresentedNoImageAlert: Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard !results.isEmpty else { return }
            parent.isProcessingImage = true
            
            results.forEach { result in
                let provider = result.itemProvider
                if provider.canLoadObject(ofClass: UIImage.self) {
                    provider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                        if let image = object as? UIImage {
                            self.parent.image = image
                        }
                        if error != nil {
                            self.parent.isPresentedNoImageAlert = true
                        }
                    })
                }
            }
        }
    }
}
