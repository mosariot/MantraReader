//
//  GoalButtonView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 18.07.2022.
//

import SwiftUI

struct GoalButtonView: View {
    @ObservedObject var viewModel: GoalButtonViewModel
    @Binding var adjustingType: AdjustingType?
    @Binding var isPresentedAdjustingAlert: Bool
    
    var body: some View {
        Button {
            adjustingType = .goal
            isPresentedAdjustingAlert = true
        } label: {
            HStack {
                Text("Goal:")
                Text("Reads Goal")
                    .numberAnimation(viewModel.mantra.readsGoal)
                    .animation(
                        viewModel.isAnimated ?
                            Animation.easeInOut(duration: Constants.animationTime) :
                            Animation.linear(duration: 0.01),
                        value: viewModel.mantra.readsGoal)
                    .padding(.leading, -3)
                
            }
        }
        .font(.subheadline)
        .onReceive(viewModel.mantra.objectWillChange) { _ in
            viewModel.updateForMantraChanges()
        }
    }
}
