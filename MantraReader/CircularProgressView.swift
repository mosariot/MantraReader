//
//  CircularProgressView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 17.06.2022.
//

import SwiftUI

struct CircularProgressView: View {
    @StateObject var viewModel: CircularProgressViewModel
    
    var body: some View {
        VStack {
            ZStack {
                PercentageRing(
                    ringWidth: 20, percent: viewModel.progress * 100,
                    backgroundColor: .red.opacity(0.2),
                    foregroundColors: [
                        Color(red: 0.880, green: 0.000, blue: 0.100),
                        Color(red: 1.000, green: 0.200, blue: 0.540)
                    ]
                )
                .animation(
                    viewModel.isAnimated ?
                        Animation.easeOut(duration: Constants.animationTime) :
                        Animation.linear(duration: 0.01),
                    value: viewModel.progress
                )
                Text("\(viewModel.displayedReads, specifier: "%.0f")")
                    .font(.system(.largeTitle, design: .rounded, weight: .medium))
                    .textSelection(.enabled)
                    .bold()
                    .dynamicTypeSize(.medium)
            }
        }
        .onReceive(viewModel.mantra.objectWillChange) { _ in
            viewModel.updateForMantraChanges()
        }
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(
            viewModel: CircularProgressViewModel(PersistenceController.previewMantra)
        )
        .padding()
    }
}
