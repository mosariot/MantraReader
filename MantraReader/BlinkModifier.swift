//
//  BlinkModifier.swift
//  MantraReader
//
//  Created by Александр Воробьев on 25.07.2022.
//

import SwiftUI

struct BlinkingModifier: ViewModifier {
    let state: Binding<Bool>
    let opacity: Double
    let duration: Double

    private var blinking: Binding<Bool> {
        Binding<Bool>(
            get: {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    state.wrappedValue = false
                }
                return state.wrappedValue
            },
            set: {
                state.wrappedValue = $0
            }
        )
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(blinking.wrappedValue ? opacity : 0)
            .animation(
                .easeOut(duration: duration),
                value: state.wrappedValue
            )
    }
}

extension View {
    func blink(on state: Binding<Bool>, opacity: Double, duration: Double) -> some View {
        self.modifier(
            BlinkingModifier(state: state, opacity: opacity, duration: duration)
        )
    }
}
