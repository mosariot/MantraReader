//
//  AdaptiveListStyle.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 07.09.2022.
//

import SwiftUI

struct AdaptiveListStyle: ViewModifier {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    func body(content: Content) -> some View {
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
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
