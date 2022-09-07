//
//  AdaptiveListStyle.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 07.09.2022.
//

import SwiftUI

struct AdaptiveListStyle: ViewModifier {
    func body(content: Content) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            content.listStyle(.insetGrouped)
        } else {
            content.listStyle(.sidebar)
        }
    }
}

extension View {
    func adaptiveListStyle() -> some View {
        modifier(AdaptiveListStyle())
    }
}
