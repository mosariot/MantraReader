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
            .listRowBackground(Color.black)
            Section("TITLE") {
                Text(mantra.title ?? "")
            }
            Section("MANTRA TEXT") {
                Text(mantra.text ?? "")
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
                    CloseButtonImage()
                }
            }
        }
    }
}
