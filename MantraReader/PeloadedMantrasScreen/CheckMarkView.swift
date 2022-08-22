//
//  CheckMarkView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 01.08.2022.
//

import SwiftUI

struct CheckMarkView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.gray)
                .cornerRadius(10)
            VStack {
                Image(systemName: "checkmark")
                    .font(.system(size: 54))
                    .foregroundColor(.white)
                Text("Added")
                    .font(.footnote)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .padding(.top, 3)
            }
        }
        .opacity(0.9)
        .frame(width: 100, height: 100)
        .offset(y: -50)
        .transition(
            .scale(scale: 1.3, anchor: .top)
            .combined(with: .opacity)
            .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.5, blendDuration: 0.2))
        )
    }
}

//struct CheckMarkView_Previews: PreviewProvider {
//    static var previews: some View {
//        CheckMarkView()
//    }
//}
