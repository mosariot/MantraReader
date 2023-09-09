//
//  InfoView.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 27.09.2022.
//

import SwiftUI
import UIKit

struct InfoView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var mantra: Mantra
    
    private var image: UIImage {
        if let data = mantra.image, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: Constants.defaultImage)!
        }
    }
    private var round: String { "\(mantra.round)" }
    
    var body: some View {
        List {
            HStack {
                Spacer()
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                Spacer()
            }
            .listRowBackground(Color.clear)
            Section("TITLE") {
                Text(mantra.title ?? "")
            }
            Section("MANTRA TEXT") {
                Text(mantra.text ?? "")
            }
            Section("READINGS IN ROUND") {
                Text(round)
            }
            Section("DESCRIPTION") {
                Text(mantra.details ?? "")
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    if #available(watchOS 10, *) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray.opacity(0.6))
                    } else {
                        CloseButtonImage()
                    }
                }
            }
        }
    }
}
