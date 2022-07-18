//
//  GoalButtonView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 18.07.2022.
//

import SwiftUI

struct GoalButtonView: View {
    @StateObject var viewModel: GoalButtonViewModel
    @Binding var adjustingType: AdjustingType?
    @Binding var isPresentedAdjustingAlert: Bool
    
    var body: some View {
        Button("Current goal: \(viewModel.displayedGoal, specifier: "%.0f")") {
            adjustingType = .goal
            isPresentedAdjustingAlert = true
        }
        .onReceive(viewModel.mantra.objectWillChange) { _ in
            viewModel.updateForMantraChanges()
        }
    }
}

import CoreData

struct GoalButtonView_Previews: PreviewProvider {
    static var controller = PersistenceController.preview
    static func previewMantra(viewContext: NSManagedObjectContext) -> Mantra {
        var mantras = [Mantra]()
        let request = NSFetchRequest<Mantra>(entityName: "Mantra")
        do {
            try mantras = viewContext.fetch(request)
        } catch {
            print("Error getting data. \(error.localizedDescription)")
        }
        return mantras[Int.random(in: 0...mantras.count-1)]
    }
    
    static var previews: some View {
        GoalButtonView(
            viewModel: GoalButtonViewModel(
                previewMantra(viewContext: controller.container.viewContext)
            ),
            adjustingType: .constant(.reads),
            isPresentedAdjustingAlert: .constant(false)
        )
        .previewDisplayName("Goal Button View")
    }
}
