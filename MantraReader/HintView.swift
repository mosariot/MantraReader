//
//  HintView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 26.07.2022.
//

import SwiftUI

struct HintView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.gray)
                .cornerRadius(10)
            VStack {
                Text("\(Image(systemName: "hand.draw")) = \(Image(systemName: "plus.circle"))")
                    .scaledToFill()
                    .lineLimit(1)
                    .padding(.vertical, 2)
                Text("\(Image(systemName: "hand.draw")) + \(Image(systemName: "hand.draw")) = \(Image(systemName: "arrow.clockwise.circle"))")
                    .scaledToFill()
                    .lineLimit(1)
                    .padding(.vertical, 2)
            }
            .padding(.horizontal, 5)
            .foregroundColor(.white)
        }
        .opacity(0.9)
        .frame(width: 100, height: 100)
    }
}

struct HintView_Previews: PreviewProvider {
    static var previews: some View {
        HintView()
    }
}
