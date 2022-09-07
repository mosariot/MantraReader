//
//  OnboardingView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 04.08.2022.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    
    private var textFont: Font {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .title2
        } else {
            return .body
        }
    }
    
    var body: some View {
        VStack {
            Text("Welcome to the path of Enlightenment!")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top)
                .padding(.horizontal)
            Image(Constants.defaultImage)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 150)
            ScrollView {
                Text(
    """
    Recitation of mantras is a sacrament.
    Approach this issue with all your awareness.
    In order for the practice of reciting the mantra to be correct, one must receive the transmission of the mantra from the teacher. Transmission is essential to maintain the strength of the original source of the mantra. It’s not enough just to read it in a book or on the Internet.
    For this reason, at start application doesn't include the mantra texts themselves (except Vajrasattva). They must be given to you by your spiritual mentor and can be added manually later.
    We wish you deep awarenesses and spiritual growth!
    """
                )
                .font(textFont)
                .padding()
            }
            Button {
                isPresented = false
            } label: {
                Text("UNDERSTAND!")
                    .font(.callout)
                    .bold()
                    .padding(.vertical, 5)
                    .padding(.horizontal, 25)
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
    }
}
