//
//  NumberAnimation.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 11.09.2022.
//

import SwiftUI

struct NumberAnimation: Animatable, ViewModifier {
    var number: Int32

    var animatableData: CGFloat {
        get { CGFloat(number) }
        set { number = Int32(newValue) }
    }

    func body(content: Content) -> some View {
        Text("\(number)")
    }
}

extension View {
    func numberAnimation(_ number: Int32) -> some View {
        modifier(NumberAnimation(number: number))
    }
}
