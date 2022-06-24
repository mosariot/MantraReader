//
//  ReadsView.swift
//  MantraReader
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

import CoreData

struct ReadsView_Previews: PreviewProvider {
    static var controller = PersistenceController.preview
    static func previewMantra(container: NSPersistentCloudKitContainer) -> Mantra {
        var mantras = [Mantra]()
        let request = NSFetchRequest<Mantra>(entityName: "Mantra")
        do {
            try data = container.viewContext.fetch(request)
        } catch {
            print("Error getting data. \(error.localizedDescription)")
        }
        return mantras.first!
    }
    
    static var previews: some View {
        ReadsView(viewModel: ReadsViewModel(previewMantra(controller.container)))
            .environment(\.managedObjectContext, controller.container.viewContext)
    }
}
