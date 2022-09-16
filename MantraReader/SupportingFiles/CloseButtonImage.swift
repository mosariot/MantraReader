//
//  CloseButtonImage.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 16.09.2022.
//

import SwiftUI

struct CloseButtonImage: View {
    var body: some View {
        Image(systemName: "xmark")
            .symbolVariant(.circle.fill)
            .foregroundColor(.gray.opacity(0.6))
            .scaleEffect(1.2)
    }
}
