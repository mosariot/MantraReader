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
        Button("Goal: \(viewModel.displayedGoal, specifier: "%.0f")") {
            adjustingType = .goal
            isPresentedAdjustingAlert = true
        }
        .font(.subheadline)
        .onReceive(viewModel.mantra.objectWillChange) { _ in
            viewModel.updateForMantraChanges()
        }
    }
}

//struct GoalButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        GoalButtonView(
//            viewModel: GoalButtonViewModel(PersistenceController.previewMantra),
//            adjustingType: .constant(.reads),
//            isPresentedAdjustingAlert: .constant(false)
//        )
//    }
//}
