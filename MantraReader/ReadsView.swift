//
//  ReadsView.swift
//  MantraReaderIdeas
//
//  Created by Александр Воробьев on 17.06.2022.
//

import SwiftUI

struct ReadsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var viewModel: ReadsViewModel
    @State private var actualReadingsString: String = ""
    @State private var actualGoalString: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            NumericTextField("Enter New Readings", text: $actualReadingsString)
                .frame(width: 200)
            
            Button("Change") {
                viewModel.animateReadsChanges(with: actualReadingsString)
                saveContext()
                actualReadingsString = ""
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
            CircularProgressView(
                progress: viewModel.progress,
                displayedNumber: viewModel.displayedReads,
                isAnimated: viewModel.isAnimated
            )
            .frame(width: 200, height: 200)
            .padding()
            
            Text("Current goal: \(viewModel.displayedGoal)")
                .foregroundColor(.gray)
            
            NumericTextField("Enter New Goal", text: $actualGoalString)
                .frame(width: 200)
                .padding()
            
            Button("Change") {
                viewModel.animateGoalsChanges(with: actualGoalString)
                saveContext()
                actualGoalString = ""
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
    }
    
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct ReadsView_Previews: PreviewProvider {
    static var controller = PersistenceController.preview
    
    static var previews: some View {
        ReadsView(viewModel: ReadsViewModel(controller.mantras.first!))
            .environment(\.managedObjectContext, controller.container.viewContext)
    }
}
