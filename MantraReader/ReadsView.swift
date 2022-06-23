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
    @State private var readingsString: String = ""
    @State private var goalString: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            NumericTextField("Enter New Readings", text: $readingsString)
                .frame(width: 200)
            
            Button("Change") {
                viewModel.animateReadsChanges(with: readingsString)
                saveContext()
                readingsString = ""
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
            CircularProgressView(
                progress: viewModel.progress,
                displayedNumber: viewModel.displayedReads,
                displayedGoal: viewModel.displayedGoal,
                isAnimated: viewModel.isAnimated
            )
            .frame(width: 200, height: 200)
            .padding()
            
            NumericTextField("Enter New Goal", text: $goalString)
                .frame(width: 200)
                .padding()
            
            Button("Change") {
                viewModel.animateGoalsChanges(with: goalString)
                saveContext()
                goalString = ""
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
