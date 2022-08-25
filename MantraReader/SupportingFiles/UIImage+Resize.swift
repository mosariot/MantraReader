//
//  UIImage+Resize.swift
//  ReadTheMantra
//
//  Created by Alex Vorobiev on 24.04.2021.
//

#if os(iOS)
import UIKit

extension UIImage {
    func resize(to targetSize: CGSize) -> UIImage {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        let scaledImageRectSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        let renderer = UIGraphicsImageRenderer(size: scaledImageRectSize)
        let scaledImage = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: scaledImageRectSize))
        }
        return scaledImage
    }
}
#elseif os(macOS)
import AppKit

extension NSImage {
    func resize(to targetSize: CGSize) -> NSImage {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        let scaledImageRectSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        let renderer = NSGraphicsImageRenderer(size: scaledImageRectSize)
        let scaledImage = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: scaledImageRectSize))
        }
        return scaledImage
    }
}
#endif
