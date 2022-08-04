//
//  OnboardingView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 04.08.2022.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Image("DefaultImage")
                .resizable()
                .scaledToFit()
                .frame(minHeight: 30)
            
            Text(
    """
    Recitation of mantras is a sacrament.
    Approach this issue with all your awareness.
    In order for the practice of reciting the mantra to be correct, one must receive the transmission of the mantra from the teacher. Transmission is essential to maintain the strength of the original source of the mantra. It’s not enough just to read it in a book or on the Internet.
    For this reason, at start application doesn't include the mantra texts themselves (except Vajrasattva). They must be given to you by your spiritual mentor and can be added manually later.
    We wish you deep awarenesses and spiritual growth!
    """
            )
            .padding()
            .layoutPriority(1)
            
            Button("UNDERSTAND!") {
                isPresented = false
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isPresented: .constant(true))
    }
}
